# Sistema de Recomendação de Música com Neo4j 🎵

Este projeto foi desenvolvido como parte de um desafio prático da **DIO (Digital Innovation One)** em parceria com a **Neo4j**. O objetivo é construir um sistema de recomendação musical utilizando um banco de dados orientado a grafos.

## 🧠 O Modelo de Grafo

O banco de dados modela as interações entre usuários, artistas, músicas e Generos através da seguinte estrutura de Nós e Relacionamentos:

### Nós (Nodes)

- **`(:User)`**: Representa os usuários do sistema. Contém propriedades como `nome` e `idade`.
- **`(:Artist)`**: Representa os artistas musicais. Identificados por `artist_id` e `nome`.
- **`(:Musica)`**: Representa as faixas de música. Contém dados como `nome`, `ano` e métricas do Spotify.
- **`(:Genero)`**: Representa os gêneros musicais (tags).

### Relacionamentos (Relationships)

- `(:User)-[:ESCUTOU {plays: Int}]->(:Musica)`: Indica que um usuário ouviu uma música específica.
- `(:User)-[:SEGUE]->(:Artist)`: Indica que o usuário segue um artista.
- `(:Artist)-[:CANTA]->(:Musica)`: Relaciona a música ao seu intérprete.
- `(:Musica)-[:PERTENCE_AO]->(:Genero)`: Classifica a música em um ou mais gêneros.

## 🚀 Como Rodar

### Pré-requisitos

- **Neo4j Desktop** ou **Neo4j Aura** instalado e rodando.
- Arquivos de dados (`User_Listening_History.csv` e `Music_Info.csv`) colocados na pasta `import` do seu banco de dados.

### Passo a Passo

1.  **Carregar os Dados**: Execute o script Cypher de importação para criar os nós e relacionamentos a partir dos CSVs.

    - _Certifique-se de criar as Constraints (índices) primeiro para garantir a performance._

2.  **Gerar Recomendações**: Utilize as queries de recomendação disponíveis para sugerir músicas.
    - **Exemplo (Recomendação baseada em Gênero):**
      ```cypher
      // Encontra músicas de gêneros que o usuário gosta, mas ainda não ouviu
      MATCH (me:User {user_id: "ID_DO_USUARIO"})-[:ESCUTOU]->(m:Musica)-[:PERTENCE_AO]->(g:Genero)
      WITH me, g, COUNT(*) AS interesse
      ORDER BY interesse DESC LIMIT 1
      MATCH (rec:Musica)-[:PERTENCE_AO]->(g)
      WHERE NOT (me)-[:ESCUTOU]->(rec)
      RETURN rec.name, g.tag
      LIMIT 5
      ```

## 🛠 Tecnologias

- **Neo4j**: Banco de dados de grafos.
- **Cypher**: Linguagem de consulta para grafos.

