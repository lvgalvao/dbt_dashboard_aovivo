import streamlit as st
import pandas as pd
import psycopg2
import altair as alt

@st.cache_resource
def load_data():
    # Conectar ao banco de dados PostgreSQL
    conn = psycopg2.connect(
        host="",
        database="",
        user="",
        password=""
    )
    
    query = """
    SELECT
        n_nota,
        data_de_pregao,
        qted,
        mercadoria,
        txop,
        tx_corretagem,
        cotacao,
        movimentacao,
        cv
    FROM
        gold_fatura;
    """
    
    df = pd.read_sql(query, conn) ## dataframe
    conn.close()
    return df

df = load_data()

# Convertendo a coluna data_de_pregao para datetime.date para evitar conflitos de tipo
df['data_de_pregao'] = pd.to_datetime(df['data_de_pregao']).dt.date

# Filtros
st.sidebar.header("Filtros")
mercadoria_selecionada = st.sidebar.multiselect(
    "Selecione a Mercadoria:",
    options=df["mercadoria"].unique(),
    default=df["mercadoria"].unique()
)

data_selecionada = st.sidebar.date_input(
    "Selecione o intervalo de datas:",
    value=[df["data_de_pregao"].min(), df["data_de_pregao"].max()]
)

df_filtered = df[(df["mercadoria"].isin(mercadoria_selecionada)) & 
                 (df["data_de_pregao"].between(data_selecionada[0], data_selecionada[1]))]

# Mostrar o DataFrame na interface do Streamlit
st.title("KPIs e Gráficos Financeiros - Gold Fatura")
st.write("Tabela de dados filtrados:")
st.dataframe(df_filtered)

# Calcular KPIs
total_movimentacao = df_filtered['movimentacao'].sum()
total_qted = df_filtered['qted'].sum()

# Mostrar KPIs
st.header("KPIs")
col1, col2 = st.columns(2)
col1.metric(label="Total Movimentação", value=f"R${total_movimentacao:,.2f}")
col2.metric(label="Total Quantidade (qted)", value=f"{total_qted:,}")

# Gráfico de quantidade (qted) por mercadoria
st.header("Quantidade por Mercadoria")
qted_chart = alt.Chart(df_filtered).mark_bar().encode(
    x='mercadoria:N',
    y='qted:Q',
    color='mercadoria:N'
).properties(
    title='Quantidade Total por Mercadoria'
)
st.altair_chart(qted_chart, use_container_width=True)

# Gráfico de movimentação ao longo do tempo
st.header("Movimentação ao longo do tempo")
movimentacao_chart = alt.Chart(df_filtered).mark_line().encode(
    x='data_de_pregao:T',
    y='movimentacao:Q',
    color='mercadoria:N'
).properties(
    title='Movimentação por Mercadoria ao Longo do Tempo'
)
st.altair_chart(movimentacao_chart, use_container_width=True)