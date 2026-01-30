-- =========================================================
-- HABITUS (Supabase / PostgreSQL) - Schema public
-- =========================================================
-- Cria Base de dados

-- drop database if exists Habitus;
-- create database Habitus;

-- 1) DROP TABLES (ordem por dependências)

DROP TABLE IF EXISTS meal_item;
DROP TABLE IF EXISTS water_intake;
DROP TABLE IF EXISTS sleep_session;
DROP TABLE IF EXISTS meal;
DROP TABLE IF EXISTS food;
DROP TABLE IF EXISTS users;


-- 2) DROP TYPES

DROP TYPE IF EXISTS water_source_enum;
DROP TYPE IF EXISTS gender_enum;

-- 3) CREATE TYPES (iguais ao simplificado)

CREATE TYPE gender_enum AS ENUM ('M', 'F', 'O');
CREATE TYPE water_source_enum AS ENUM ('manual', 'bottle');


-- 4) BASE 

CREATE TABLE users (
  user_id       SERIAL PRIMARY KEY,
  email         VARCHAR(45) NOT NULL UNIQUE,
  full_name     VARCHAR(60) NOT NULL,
  password_hash VARCHAR(60) NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  birth_date    DATE,
  gender        public.gender_enum,
  height_cm     INT,
  weight_kg     INT,
  phone         VARCHAR(45)
);

CREATE TABLE water_intake (
  water_intake_id SERIAL PRIMARY KEY,
  intake_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  amount_ml       INT NOT NULL DEFAULT 0,
  source          water_source_enum NOT NULL DEFAULT 'manual',
  user_id         INT NOT NULL,
  CONSTRAINT fk_water_intake_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
);

CREATE INDEX IF NOT EXISTS idx_water_intake_user_id
  ON water_intake(user_id);

-- meal (simplificado)
CREATE TABLE meal (
  meal_id     SERIAL PRIMARY KEY,
  meal_type   VARCHAR(45),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes       TEXT,
  user_id     INT NOT NULL,
  CONSTRAINT fk_meal_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
);

CREATE INDEX IF NOT EXISTS idx_meal_user_id
  ON meal(user_id);

CREATE TABLE food (
  food_id        SERIAL PRIMARY KEY,
  name           VARCHAR(45) NOT NULL,
  kcal_per_100g  NUMERIC(10,2),
  protein_g      NUMERIC(10,2),
  carbs_g        NUMERIC(10,2),
  fat_g          NUMERIC(10,2)
);

CREATE TABLE meal_item (
  meal_item_id  SERIAL PRIMARY KEY,
  quantity      NUMERIC(10,2) NOT NULL,
  unit_name     VARCHAR(45) NOT NULL,
  kcal_override NUMERIC(10,2) NOT NULL,
  meal_id       INT NOT NULL,
  food_id       INT NOT NULL,
  CONSTRAINT fk_meal_item_meal
    FOREIGN KEY (meal_id)
    REFERENCES public.meal(meal_id),
  CONSTRAINT fk_meal_item_food
    FOREIGN KEY (food_id)
    REFERENCES public.food(food_id)
);

CREATE INDEX IF NOT EXISTS idx_meal_item_meal_id
  ON meal_item(meal_id);

CREATE INDEX IF NOT EXISTS idx_meal_item_food_id
  ON meal_item(food_id);

CREATE TABLE sleep_session (
  sleep_session_id SERIAL PRIMARY KEY,
  start_time       TIMESTAMPTZ NOT NULL,
  end_time         TIMESTAMPTZ NOT NULL,
  quality_score    INT NOT NULL,
  user_id          INT NOT NULL,
  CONSTRAINT fk_sleep_session_user
    FOREIGN KEY (user_id)
    REFERENCES public.users(user_id),
  CONSTRAINT chk_sleep_time
    CHECK (end_time >= start_time)
);

CREATE INDEX IF NOT EXISTS idx_sleep_session_user_id
  ON sleep_session(user_id);


-- Ativar RLS 

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE food ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_session ENABLE ROW LEVEL SECURITY;




-- Inserts -- 
INSERT INTO users (email, full_name, password_hash, updated_at, birth_date, gender, height_cm, weight_kg, phone)
VALUES 
('ana.silva@gmail.com', 'Ana Rita Silva', 'hash_ana_001', NOW(), '1998-05-14', 'F', 165, 58, 912345678),
('joao.costa@gmail.com', 'João Maria Marques Costa', 'hash_joao_001', NOW(), '1995-11-02', 'M', 178, 82, 934567890),
('maria.rodrigues@outlook.com', 'Maria Leonor Rodrigues', 'hash_maria_001', NOW(), '2001-01-28', 'F', 170, 64, NULL),
('tiago.fernandes@sapo.pt', 'Tiago Miguel Fernandes', 'hash_tiago_001', NOW(), '1999-08-09', 'M', NULL, NULL, 967890123),
('alex.sousa@gmail.com', 'Alex Sousa', 'hash_alex_001', NOW(), '2000-03-21', 'O', 172, 70, 911112223),
('ana.s.barbas@gmail.com', 'Ana Silva', 'hash1', NOW(), '1998-03-14', 'F', 165, 58, 912345698),
('joao.c.tretas@gmail.com', 'João Costa', 'hash2', NOW(), '1995-10-02', 'M', 178, 82, 934566789),
('m.r@outlook.com', 'Maria Rodrigues', 'hash3', NOW(), '2001-01-30', 'F', 190, 78, NULL),
('t.f@sapo.pt', 'Tiago Fernandes', 'hash4', NOW(), '1999-04-09', 'M', NULL, NULL, 967899993),
('a.sa@gmail.com', 'Alex Sa', 'hash5', NOW(), '2010-03-21', 'O', 172, 70, 923112223),
('beatriz.mendes@gmail.com', 'Beatriz Mendes', 'hash6', NOW(), '1997-12-10', 'F', 160, 55, 913334445),
('ricardo.pires@gmail.com', 'Ricardo Pires', 'hash7', NOW(), '1994-04-18', 'M', 182, 90, 914445556),
('ines.lopes@gmail.com', 'Inês Lopes', 'hash8', NOW(), '2002-06-02', 'F', 168, 62, NULL),
('diogo.santos@gmail.com', 'Diogo Santos', 'hash9', NOW(), '1996-09-27', 'M', 175, 77, 916667778),
('carla.ribeiro@gmail.com', 'Carla Ribeiro', 'hash10', NOW(), '1993-03-05', 'F', 162, 59, 918889990);

INSERT INTO water_intake (intake_at, amount_ml, source, user_id)
VALUES
('2026-01-10 09:00:00', 250, 'bottle', 1),
('2026-01-10 11:30:00', 500, 'bottle', 1),
('2026-01-10 15:00:00', 330, 'bottle', 1),
('2026-01-10 10:15:00', 500, 'manual', 2),
('2026-01-10 18:45:00', 250, 'manual', 2),
('2026-01-11 16:45:00', 200, 'manual', 3),
('2026-01-11 09:15:00', 300, 'manual', 1),
('2026-01-11 11:45:00', 500, 'bottle', 1),
('2026-01-12 10:00:00', 250, 'manual', 1),
('2026-01-11 09:30:00', 500, 'bottle', 2),
('2026-01-11 14:00:00', 330, 'manual', 2),
('2026-01-12 16:30:00', 250, 'manual', 2),
('2026-01-12 10:15:00', 200, 'manual', 3),
('2026-01-12 18:20:00', 400, 'bottle', 3),
('2026-01-11 08:50:00', 250, 'manual', 4),
('2026-01-11 12:10:00', 250, 'manual', 4),
('2026-01-12 09:00:00', 500, 'bottle', 5);

INSERT INTO sleep_session (start_time, end_time, quality_score, user_id)
VALUES
('2026-01-09 23:40:00', '2026-01-10 07:15:00', 82, 1),
('2026-01-10 23:55:00', '2026-01-11 08:05:00', 90, 1),
('2026-01-10 00:10:00', '2026-01-10 06:50:00', 70, 2),
('2026-01-10 23:30:00', '2026-01-11 07:10:00', 20, 3),
('2026-01-11 23:50:00', '2026-01-12 07:30:00', 88, 1),
('2026-01-11 00:30:00', '2026-01-11 06:45:00', 65, 2),
('2026-01-12 01:10:00', '2026-01-12 07:00:00', 72, 2),
('2026-01-11 23:20:00', '2026-01-12 08:10:00', 92, 3),
('2026-01-11 02:00:00', '2026-01-11 06:00:00', 40, 4),
('2026-01-12 00:00:00', '2026-01-12 07:40:00', 80, 5);

INSERT INTO food (name, kcal_per_100g, protein_g, carbs_g, fat_g)
VALUES 
('Arroz cozido', 130, 2.7, 28.0, 0.3),
('Peito de frango', 165, 31.0, 0.0, 3.6),
('Ovo', 155, 13.0, 1.1, 11.0),
('Banana', 89, 1.1, 23.0, 0.3),
('Aveia', 389, 16.9, 66.3, 6.9),
('Iogurte natural', 61, 3.5, 4.7, 3.3),
('Salmão', 208, 20.0, 0.0, 13.0),
('Brócolos', 34, 2.8, 7.0, 0.4),
('Pão integral', 247, 13.0, 41.0, 4.2),
('Maçã', 52, 0.3, 14.0, 0.2);

INSERT INTO meal (meal_type, created_at, notes, user_id)
VALUES
('Pequeno-almoço', '2026-01-10 08:10:00', 'Aveia com banana e iogurte', 1),
('Almoço', '2026-01-10 13:05:00', 'Frango com arroz e brócolos', 1),
('Jantar', '2026-01-10 20:30:00', NULL, 1),
('Pequeno-almoço', '2026-01-10 07:40:00', 'Ovos mexidos e pão', 2),
('Almoço', '2026-01-10 12:50:00', NULL, 2),
('Snack', '2026-01-11 16:20:00', 'Fruta da tarde', 3),
('Snack', '2026-01-11 17:00:00', 'Iogurte e maçã', 1),
('Almoço', '2026-01-12 13:10:00', NULL, 1),
('Jantar', '2026-01-11 20:40:00', 'Salmão e brócolos', 2),
('Snack', '2026-01-12 16:10:00', 'Banana', 2),
('Pequeno-almoço', '2026-01-12 08:30:00', NULL, 3),
('Almoço', '2026-01-11 13:30:00', 'Arroz com ovos', 4),
('Jantar', '2026-01-12 21:00:00', 'Frango grelhado', 5);


INSERT INTO meal_item(quantity, unit_name, kcal_override, meal_id, food_id)
VALUES 
(80,  'g', (select kcal_per_100g from food where name='Aveia')/100*80, 1, (SELECT food_id FROM food WHERE name='Aveia')),
(120, 'g', (select kcal_per_100g from food where name='Banana')/100*120, 1, (SELECT food_id FROM food WHERE name='Banana')),
(150, 'g', (select kcal_per_100g from food where name='Iogurte natural')/100*150, 1, (SELECT food_id FROM food WHERE name='Iogurte natural')),
(200, 'g', (select kcal_per_100g from food where name='Peito de frango')/100*200, 2, (SELECT food_id FROM food WHERE name='Peito de frango')),
(180, 'g', (select kcal_per_100g from food where name='Arroz cozido')/100*180, 2, (SELECT food_id FROM food WHERE name='Arroz cozido')),
(120, 'g', (select kcal_per_100g from food where name='Brócolos')/100*120, 2, (SELECT food_id FROM food WHERE name='Brócolos')),
(180, 'g', (select kcal_per_100g from food where name='Salmão')/100*180, 3, (SELECT food_id FROM food WHERE name='Salmão')),
(150, 'g', (select kcal_per_100g from food where name='Brócolos')/100*150, 3, (SELECT food_id FROM food WHERE name='Brócolos')),
(2, 'un', (select kcal_per_100g from food where name='Ovo')*2, 4, (SELECT food_id FROM food WHERE name='Ovo')),
(90, 'g', (select kcal_per_100g from food where name='Pão integral')/100*90, 4, (SELECT food_id FROM food WHERE name='Pão integral')),
(220, 'g', (select kcal_per_100g from food where name='Peito de frango')/100*220, 5, (SELECT food_id FROM food WHERE name='Peito de frango')),
(200, 'g', (select kcal_per_100g from food where name='Arroz cozido')/100*200, 5, (SELECT food_id FROM food WHERE name='Arroz cozido')),
(160, 'g', (select kcal_per_100g from food where name='Maçã')/100*160, 6, (SELECT food_id FROM food WHERE name='Maçã')),
(120, 'g', (select kcal_per_100g from food where name='Banana')/100*120, 6, (SELECT food_id FROM food WHERE name='Banana')),
(125, 'g', (SELECT kcal_per_100g FROM food WHERE name='Iogurte natural')/100*125, 7, (SELECT food_id FROM food WHERE name='Iogurte natural')),
(150, 'g', (SELECT kcal_per_100g FROM food WHERE name='Maçã')/100*150, 7, (SELECT food_id FROM food WHERE name='Maçã')),
(200, 'g', (SELECT kcal_per_100g FROM food WHERE name='Peito de frango')/100*200, 8, (SELECT food_id FROM food WHERE name='Peito de frango')),
(180, 'g', (SELECT kcal_per_100g FROM food WHERE name='Salmão')/100*180, 8, (SELECT food_id FROM food WHERE name='Salmão')),
(180, 'g', (SELECT kcal_per_100g FROM food WHERE name='Salmão')/100*180, 9, (SELECT food_id FROM food WHERE name='Salmão')),
(120, 'g', (SELECT kcal_per_100g FROM food WHERE name='Brócolos')/100*120, 9, (SELECT food_id FROM food WHERE name='Brócolos')),
(120, 'g', (SELECT kcal_per_100g FROM food WHERE name='Banana')/100*120, 10, (SELECT food_id FROM food WHERE name='Banana')),
(80, 'g', (SELECT kcal_per_100g FROM food WHERE name='Aveia')/100*80, 11, (SELECT food_id FROM food WHERE name='Aveia')),
(120, 'g', (SELECT kcal_per_100g FROM food WHERE name='Banana')/100*120, 11, (SELECT food_id FROM food WHERE name='Banana')),
(180, 'g', (SELECT kcal_per_100g FROM food WHERE name='Arroz cozido')/100*180, 12, (SELECT food_id FROM food WHERE name='Arroz cozido')),
(2, 'un', (SELECT kcal_per_100g FROM food WHERE name='Ovo')*2, 12, (SELECT food_id FROM food WHERE name='Ovo')),
(220, 'g', (SELECT kcal_per_100g FROM food WHERE name='Peito de frango')/100*220, 13, (SELECT food_id FROM food WHERE name='Peito de frango'));
