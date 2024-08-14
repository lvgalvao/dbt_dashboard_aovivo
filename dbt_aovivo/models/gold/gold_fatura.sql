WITH cte_silver_fatura_jornada AS (
    SELECT
        cv,
        n_nota,
        data_de_pregao,
        qted,
        mercadoria,
        txop,
        tx_corretagem,
        cotacao,
        movimentacao
    FROM
        {{ ref('silver_fatura_jornada') }}
),

cte_silver_fatura_redrex AS (
    SELECT
        cv,
        n_nota,
        data_de_pregao,
        qted,
        mercadoria,
        txop,
        tx_corretagem,
        cotacao,
        movimentacao
    FROM
        {{ ref('silver_fatura_redrex') }}
)

SELECT * 
FROM cte_silver_fatura_jornada

UNION ALL

SELECT * 
FROM cte_silver_fatura_redrex
