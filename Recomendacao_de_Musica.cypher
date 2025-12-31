CREATE CONSTRAINT user_id if NOT EXISTS FOR (u:User) REQUIRE u.user_id IS UNIQUE;
CREATE CONSTRAINT artist_id IF NOT EXISTS FOR (a:Artist) REQUIRE a.artist_id IS UNIQUE;
CREATE CONSTRAINT musica_id if NOT EXISTS FOR (m:Musica) REQUIRE m.track_id IS UNIQUE;


LOAD CSV WITH HEADERS FROM "file:///Music_Info.csv" AS row1
CALL(row1){
  ///Artista
  MERGE (a:Artist {artist_id: row1.artist_id})
  ON CREATE SET a.nome = row1.artist
  ON MATCH SET a.nome = row1.artist
  
  // Musica
  MERGE (m:Musica {track_id: row1.track_id})
  ON CREATE SET m.name = row1.name,
  m.year = toInteger(row1.year),
  m.spotify_id = row1.spotify_id,
  m.spotify_preview = row1.spotify_preview_url

  ON MATCH SET m.name = row1.name,
  m.year = toInteger(row1.year),
  m.spotify_id = row1.spotify_id,
  m.spotify_preview = row1.spotify_preview_url

  // Cria o relacionamento artista -> Musica
  MERGE (a)-[:CANTA]->(m)

  // Generos|Tags
  // Quebra a string tags, e cria uma lista
  WITH m, split(row1.tags, ',') AS tagList, row1

  UNWIND tagList AS tagLimpa

  // Remove espaçamento extra (ex: " pop" vira "pop")
  WITH m, trim(tagLimpa) AS tagName, row1
  WHERE tagName <> "" // Ignora tags vazias

  // Nó Genero
  MERGE (g:Genero {tag: tagName})

  MERGE (m)-[:PERTENCE_AO]->(g)
  
} IN TRANSACTIONS OF 1000 ROWS;

LOAD CSV WITH HEADERS FROM "file:///User_Listening_History.csv" AS row2

CALL(row2){
  // Usuario
  MERGE (u:User {user_id: row2.user_id})

  ON CREATE SET u.nome = row2.nome,
  u.idade = toInteger(row2.idade)

  ON MATCH SET u.nome = row2.nome,
  u.idade = toInteger(row2.idade)

  WITH u, row2
  MATCH (m:Musica {track_id: row2.track_id})

  MERGE (u)-[r:ESCUTOU]->(m)
  SET r.plays = toInteger(row2.playcount)

  FOREACH(ignoreME IN CASE WHEN row2.segue = '1' AND row2.artist_id IS NOT NULL AND 
  row2.artist_id <> "" THEN [1] ELSE [] END |
  MERGE (a:Artist {artist_id: row2.artist_id}) 
  MERGE (u)-[:SEGUE]->(a)

)} IN TRANSACTIONS OF 1000 ROWS;


// OPÇÕES DE RECOMENDAÇÃO
// Executa depois de carregar os dados

//Recomendação segue quem eu sigo
MATCH (me:User {user_id: "b64cdd1a0bd907e5e00b39e345194768e330d652"})-[:SEGUE]->(a:Artist)<-[:SEGUE]-(other:User)
MATCH (other)-[:ESCUTOU]->(rec:Musica)
WHERE NOT (me)-[:ESCUTOU]->(rec)
RETURN rec.name AS Musica, COUNT(*) AS Score
ORDER BY Score DESC
LIMIT 10

// Recomendação por Genero e popularidade
MATCH (me:User {user_id: "b64cdd1a0bd907e5e00b39e345194768e330d652"})-[:ESCUTOU]->(m:Musica)-[:PERTENCE_AO]->(g:Genero)
WITH me, g, COUNT(*) AS gosta_genero
ORDER BY gosta_genero DESC LIMIT 1
MATCH (rec:Musica)-[:PERTENCE_AO]->(g)
WHERE NOT (me)-[:ESCUTOU]->(rec)
RETURN rec.name AS Musica, g.tag AS Genero, COUNT{(rec)<-[:ESCUTOU]-()} AS Popularidade
ORDER BY Popularidade DESC LIMIT 10
