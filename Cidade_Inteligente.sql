CREATE EXTENSION postgis;

CREATE TABLE bairros (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    limite GEOMETRY(Polygon, 4326)
);

CREATE TABLE escolas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);

CREATE TABLE hospitais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);

CREATE TABLE postos_saude (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    localizacao GEOMETRY(Point, 4326)
);

CREATE TABLE ruas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    geometria GEOMETRY(LineString, 4326)
);


INSERT INTO bairros (nome, limite) VALUES 
('Tambaú', ST_GeomFromText('POLYGON((-34.827 -7.115, -34.820 -7.115, -34.820 -7.125, -34.827 -7.125, -34.827 -7.115))', 4326));


INSERT INTO escolas (nome, localizacao) VALUES 
('Escola Municipal de Tambaú', ST_SetSRID(ST_Point(-34.823, -7.118), 4326));


INSERT INTO hospitais (nome, localizacao) VALUES 
('Hospital Santa Isabel', ST_SetSRID(ST_Point(-34.875, -7.120), 4326));


INSERT INTO postos_saude (nome, localizacao) VALUES 
('Posto de Saúde Tambaú', ST_SetSRID(ST_Point(-34.824, -7.120), 4326));


INSERT INTO ruas (nome, geometria) VALUES 
('Avenida Almirante Tamandaré', ST_GeomFromText('LINESTRING(-34.830 -7.118, -34.815 -7.118)', 4326));

-- Quais escolas estao dentro do bairro
SELECT e.nome AS escola, b.nome AS bairro
FROM escolas e
JOIN bairros b ON ST_Contains(b.limite, e.localizacao)
WHERE b.nome = 'Tambaú';

-- posto de saude proximo a uma escola
SELECT p.nome AS posto_saude, e.nome AS escola
FROM postos_saude p
JOIN escolas e ON ST_DWithin(p.localizacao::geography, e.localizacao::geography, 1500);

-- posto de hospital proximo a uma escola
SELECT e.nome AS escola, h.nome AS hospital_mais_proximo
FROM escolas e
CROSS JOIN LATERAL (
    SELECT nome
    FROM hospitais
    ORDER BY hospitais.localizacao <-> e.localizacao
    LIMIT 1
) h;

-- Ruas que intersectam o limite do bairro
SELECT r.nome AS rua, b.nome AS bairro
FROM ruas r
JOIN bairros b ON ST_Intersects(r.geometria, b.limite);


-- indeces das tabelas com gist e analisando depois com explain analyze
CREATE INDEX idx_bairros_limite ON bairros USING GIST (limite);
CREATE INDEX idx_escolas_loc ON escolas USING GIST (localizacao);
CREATE INDEX idx_hospitais_loc ON hospitais USING GIST (localizacao);
CREATE INDEX idx_postos_loc ON postos_saude USING GIST (localizacao);
CREATE INDEX idx_ruas_geom ON ruas USING GIST (geometria);

EXPLAIN ANALYZE
SELECT e.nome AS escola, b.nome AS bairro
FROM escolas e
JOIN bairros b ON ST_Contains(b.limite, e.localizacao)
WHERE b.nome = 'Tambaú';

