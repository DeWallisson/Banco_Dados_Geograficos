CREATE EXTENSION postgis;
CREATE TABLE restaurantes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);


INSERT INTO restaurantes (nome, localizacao)
VALUES ('Restaurante Central', ST_SetSRID(ST_Point(-34.845, -7.119), 4326));


SELECT id, nome, ST_AsText(localizacao) AS wkt_localizacao
FROM restaurantes;


SELECT 
    id, 
    nome, 
    ST_X(localizacao) AS longitude, 
    ST_Y(localizacao) AS latitude
FROM restaurantes;


SELECT id, nome
FROM restaurantes
WHERE ST_DWithin(
    localizacao::geography,
    ST_SetSRID(ST_Point(-34.845, -7.119), 4326)::geography,
    2000
);



CREATE TABLE bairros (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    limite GEOMETRY(Polygon, 4326)
);

INSERT INTO bairros (nome, limite) VALUES 
('Centro', ST_GeomFromText('POLYGON((-34.85 -7.12, -34.84 -7.12, -34.84 -7.11, -34.85 -7.11, -34.85 -7.12))', 4326));

CREATE TABLE escolas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);

INSERT INTO escolas (nome, localizacao) VALUES 
('Escola Modelo', ST_SetSRID(ST_Point(-34.845, -7.115), 4326));

CREATE TABLE hospitais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);

INSERT INTO hospitais (nome, localizacao) VALUES 
('Hospital Municipal', ST_SetSRID(ST_Point(-34.842, -7.112), 4326));

CREATE TABLE ruas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    geometria GEOMETRY(LineString, 4326)
);

INSERT INTO ruas (nome, geometria) VALUES 
('Avenida Principal', ST_GeomFromText('LINESTRING(-34.86 -7.13, -34.83 -7.10)', 4326));

CREATE TABLE parques (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    limite GEOMETRY(Polygon, 4326)
);

INSERT INTO parques (nome, limite) VALUES 
('Parque da Cidade', ST_GeomFromText('POLYGON((-34.848 -7.118, -34.843 -7.118, -34.843 -7.114, -34.848 -7.114, -34.848 -7.118))', 4326));


SELECT e.nome AS escola, b.nome AS bairro
FROM escolas e
JOIN bairros b ON ST_Contains(b.limite, e.localizacao);


SELECT DISTINCT h.nome AS hospital
FROM hospitais h
JOIN escolas e ON ST_DWithin(h.localizacao::geography, e.localizacao::geography, 3000);


SELECT e.nome AS escola, h.nome AS hospital_mais_proximo
FROM escolas e
CROSS JOIN LATERAL (
    SELECT nome
    FROM hospitais
    ORDER BY hospitais.localizacao <-> e.localizacao
    LIMIT 1
) h;


SELECT DISTINCT r.nome AS rua, b.nome AS bairro
FROM ruas r
JOIN bairros b ON ST_Intersects(r.geometria, b.limite);


SELECT nome, ST_Area(limite::geography) AS area_m2
FROM parques;



SELECT nome, ST_Length(geometria::geography) AS comprimento_m
FROM ruas;


CREATE INDEX idx_bairros_limite ON bairros USING GIST (limite);
CREATE INDEX idx_escolas_loc ON escolas USING GIST (localizacao);
CREATE INDEX idx_hospitais_loc ON hospitais USING GIST (localizacao);
CREATE INDEX idx_ruas_geom ON ruas USING GIST (geometria);
CREATE INDEX idx_parques_limite ON parques USING GIST (limite);