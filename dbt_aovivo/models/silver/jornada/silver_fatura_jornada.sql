WITH fatura_jornada AS (
    SELECT
        cv,
        n_nota,
        data_de_pregao,
        qted,
        mercadoria,
        txop,
        cotacao
    FROM
        {{ ref('bronze_fatura_jornada') }}
),

fatura_jornada_small AS (
    SELECT
        n_nota,
        data_de_pregao,
        tx_corretagem,
        taxa
    FROM
        {{ ref('bronze_fatura_jornada_small') }}
),

kpi_calculated AS (
    SELECT
        r.cv,
        r.n_nota,
        r.data_de_pregao,
        r.qted,
        r.mercadoria,
        r.txop,
        s.tx_corretagem,
        r.cotacao,
        CASE 
            WHEN r.cv = 'C' THEN -ROUND((r.qted * r.cotacao * (1 - (s.tx_corretagem + r.txop) / 100)), 2)
            WHEN r.cv = 'V' THEN ROUND((r.qted * r.cotacao * (1 - (s.tx_corretagem + r.txop) / 100)), 2)
            ELSE 0 -- Valor padrão caso cv não seja 'C' nem 'V'
        END AS movimentacao
    FROM
        fatura_jornada r
    JOIN
        fatura_jornada_small s
    ON
        r.n_nota = s.n_nota
        AND r.data_de_pregao = s.data_de_pregao
)

SELECT * 
FROM kpi_calculated
