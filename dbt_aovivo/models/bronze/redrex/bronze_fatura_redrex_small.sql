WITH pivot_data AS (
    SELECT
        "N Nota",
        MAX(CASE WHEN "1" = 'IRR' THEN "2" END) AS irr,
        MAX(CASE WHEN "1" = 'Ajuste' THEN "2" END) AS ajuste,
        MAX(CASE WHEN "1" = 'Tx Corretagem' THEN "2" END) AS tx_corretagem,
        MAX(CASE WHEN "1" = 'Taxa' THEN "2" END) AS taxa,
        "Data de Pregão"
    FROM
        {{ source('investimentos', 'fatura_redrex_small') }}
    GROUP BY
        "N Nota", "Data de Pregão"
),

formatted AS (
    SELECT
        "N Nota" as n_nota,
        TO_DATE("Data de Pregão", 'DDMMYYYY') AS data_de_pregao,
        CAST(REPLACE(irr, ',', '.') AS DECIMAL(10, 2)) AS irr,
        CAST(REPLACE(ajuste, ',', '.') AS DECIMAL(10, 2)) AS ajuste,
        CAST(REPLACE(tx_corretagem, ',', '.') AS DECIMAL(10, 2)) AS tx_corretagem,
        CAST(REPLACE(taxa, ',', '.') AS DECIMAL(10, 2)) AS taxa
    FROM
        pivot_data
)

SELECT * 
FROM formatted
