-- ==================   CONSULTAS ========================-- 

-- ===== Três consultas simples utilizando: SELECT, FROM, ORDER BY, LIMIT e DISTINCT.

-- Quais são os tipos de refeição únicos registados no sistema?
select distinct meal_type as "Refeição"
from meal
order by 1;

-- Quais são os 3 alimentos com maior teor calórico por 100g?
select concat(name, ' - ', kcal_per_100g) as "Alimentos mais calóricos"
from food
order by kcal_per_100g desc
limit 3;

-- Considerando a lista anterior, quais são os alimentos que ocupam as 4ª e 5ª posição?
select concat(name, ' - ', kcal_per_100g) as "Alimentos mais calóricos"
from food
order by kcal_per_100g desc
limit 2 offset 3;

-- ===== Três consultas simples utilizando: operadores, funções matemáticas, funções de texto e funções de data e hora.

-- Liste a idade dos utilizadores
select full_name as "Nome", extract(year from age(current_date, birth_date)) as "Idade"
from users;

-- Apresente o nome dos alimentos em letras maiúsculas.
select upper(name) as "Nome"
from food;

-- Qual seria o valor calórico de 150g para cada alimento (calculado a partir do valor base de 100g)?
select kcal_per_100g as "kcal por 100g", round(kcal_per_100g*1.5,2) as "kcal por 150g"
from food;

-- ===== Duas consultas simples utilizando funções de agregação.

-- Qual é a pontuação média de qualidade do sono de todos os registos?
select round(avg(quality_score),2) as "Qualidade Média de Sono"
from sleep_session;

-- Qual é o total de água (em ml) registado em todo o sistema?
select sum(amount_ml) as "Total de Água Ingerida (ml)"
from water_intake;

-- ====== Pergunta extra ----
-- Determine o desvio padrão do peso dos utilizadores, por género.
Select gender as "Género", round(avg(weight_kg),3) as "Média de Peso (Kg)", round(stddev(weight_kg),3) as "Desvio Padrão"
From users
group by gender;

-- ===== Quatro consultas utilizando WHERE e operadores lógicos.

-- Quais são os utilizadores do género feminino ('F') com altura superior a 165 cm?
select full_name as "Nome", height_cm as "Altura (cm)"
from users
where gender='F' and height_cm > 165;

-- Liste os registos de ingestão de água superiores a 300ml ou que não tenham sido feitos via 'bottle'.
select user_id as "Utilizador", intake_at as "Ingerida em", amount_ml as "Quantidade (ml)", source as "Fonte"
from water_intake
where amount_ml > 300 or source <> 'bottle';

--- Selecione alimentos que tenham mais de 10g de proteína e menos de 10g de gordura.
select name as "Alimento"
from food
where protein_g>10 and fat_g<10;

-- Procure sessões de sono que não tenham uma pontuação de qualidade inferior a 50.
select user_id as "Utilizador",  start_time as "Dia",quality_score as "Pontuação"
from sleep_session
where quality_score >=50;


-- ===== Uma consulta utilizando WHERE com o operador LIKE.

-- Quais são os utilizadores cujo nome começa por Ana ou por João(considerando que pode ser escrito de qualquer forma)?
Select full_name as "Nome"
from users
where unaccent(lower(full_name)) like 'ana %' or unaccent(lower(full_name)) like 'joao %';


-- ===== Três consultas utilizando GROUP BY e GROUP BY com HAVING

-- Qual a média de peso por género dos utilizadores?
select gender as "Género", round(avg(weight_kg),3) as "Média (Kg)", min(weight_kg) as "Mínimo (Kg)", max(weight_kg) as "Máximo (Kg)"
from users
group by 1;

-- Quais os tipos de refeição que aparecem mais de duas vezes na tabela de refeições?
select meal_type as "Refeição", count(*) as "Número de Repetições"
from meal
group by 1
having count(*)>2;

-- Quais os tipos de alimentos presentes em mais de duas refeições?
select f.name as "Alimento", count(distinct m.meal_id) as "Número de Refeições"
from food f inner join meal_item mi on f.food_id=mi.food_id
	inner join meal m on mi.meal_id=m.meal_id
group by f.name
having count(distinct m.meal_id)>2;


-- ===== Três consultas utilizando INNER JOIN para juntar duas ou mais tabelas.

-- Liste o nome do utilizador e a respetiva quantidade de água ingerida.
select u.full_name as "Nome", sum(wi.amount_ml) as "Água Ingerida (ml)"
from users u inner join water_intake wi on u.user_id=wi.user_id
group by u.full_name;

-- Mostre o tipo de refeição e o nome dos alimentos associados a cada tipo de refeição.
select m.meal_type as "Refeição", f.name as "Alimento"
from meal m inner join meal_item mi on m.meal_id=mi.meal_id inner join food f on f.food_id=mi.food_id
group by 1,2
order by 1;

-- Liste o nome dos utilizadores e a pontuação das suas sessões de sono.
select u.full_name as "Nome", s.quality_score as "Qualidade do Sono"
from users u inner join sleep_session s on u.user_id=s.user_id
group by 1,2
order by 1;

-- ===== Uma consulta utilizando LEFT/RIGHT JOIN

-- Liste todos os utilizadores e as suas ingestões de água, incluindo aqueles que ainda não registaram qualquer ingestão.
select u.full_name as "Nome", coalesce(wi.amount_ml,0) as "Água Ingerida (ml)"
from users u left join water_intake wi on u.user_id=wi.user_id;

-- ===== Uma consulta que recorra a uma VIEW

-- Crie uma vista que mostre o sumatório calórico de cada alimento, para os alimentos com mais de 100 kcal por 100g.

create or replace view meal_meal_item_food as
select m.meal_id as "meal_id", m.meal_type, m.created_at, m.notes, m.user_id, mi.meal_item_id, mi.quantity, mi.unit_name, mi.kcal_override, m.meal_id as "Refeição", mi.food_id as "alimento", f.food_id as "food_id", f.name, f.kcal_per_100g, f.protein_g, f.carbs_g, f.fat_g
from meal m inner join meal_item mi on m.meal_id=mi.meal_id 
      inner join 
      food f on f.food_id=mi.food_id

select meal_type, name, quantity, kcal_override
from meal_meal_item_food
where kcal_per_100g>100
group by 1,2,3,4
order by 1;

-- Crie uma vista que permita avaliar se o nível de hidratação interfere na qualidade de sono de cada utilizador.

create or replace view hidratacao as
select s.sleep_session_id, s.start_time, s.end_time, s.quality_score, s.user_id as "sono", u.user_id as "utilizador", u.email, u.full_name, u.password_hash, u.created_at, u.updated_at, u.birth_date, u.gender, u.height_cm, u.weight_kg, u.phone, w.water_intake_id, w.intake_at, w.amount_ml, w.source, w.user_id as "água"
from sleep_session s inner join users u on s.user_id=u.user_id
      inner join
      water_intake w on w.user_id=u.user_id

select full_name, amount_ml, quality_score
from hidratacao
order by 1;

