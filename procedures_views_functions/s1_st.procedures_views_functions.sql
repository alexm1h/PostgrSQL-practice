--Лабораторная №4
--Сессия 1
--Упражнение 1 - Использование вложенных запросов
--Задание 1
select full_name, 
(select count(*) from flight_crew fc where fc.crew_id=cm.crew_id) as flight_count 
from crew_members cm;

--Задание 2
select count(distinct fc.crew_id) as total_crew,
avg(cm.license_expiry - current_date) as avg_days_left
from (select crew_id, flight_id from flight_crew) as fc
join crew_members cm on fc.crew_id = cm.crew_id;

--Задание 3
with crew_flights as (select crew_id, flight_id from flight_crew),
crew_licenses as (select crew_id, license_expiry from crew_members)
select 
    count(distinct cf.crew_id) as total_crew,
    avg(cl.license_expiry - current_date) as avg_days_left
from crew_flights cf
join crew_licenses cl on cf.crew_id = cl.crew_id;

--Задание 4
select cm.crew_id, cm.full_name
from crew_members cm
where not exists (select 1 from flight_crew fc where fc.crew_id = cm.crew_id);