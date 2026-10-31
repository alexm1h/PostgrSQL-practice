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

--Упрежнение 2 - Использование представлений (VIEW)
--Задание 1
create or replace view crew_flight_view as
select 
    cm.full_name, 
    cm.role, 
    f.route_no as flight_no, 
    f.scheduled_departure
from crew_members cm
join flight_crew fc on cm.crew_id = fc.crew_id
join flights f on fc.flight_id = f.flight_id;

select * from crew_flight_view limit 10;

--Задание 2
create materialized view airport_flights_crew_mv as
select 
    a.airport_code,
    a.airport_name, 
    f.flight_id, 
    f.scheduled_departure,
    cm.full_name, 
    cm.role
from airports_data a
join routes r on a.airport_code = r.departure_airport
join flights f on r.route_no = f.route_no
join flight_crew fc on f.flight_id = fc.flight_id
join crew_members cm on fc.crew_id = cm.crew_id;

select * from airport_flights_crew_mv limit 10;

--Задание 3
create index index_airport_flights_mv on airport_flights_crew_mv (flight_id);

select * from pg_indexes where tablename = 'airport_flights_crew_mv';

--Упражнение 3 – Использование функций и процедур
--Задание 1
create or replace function count_valid_licenses()
returns integer as $$
declare
    total integer;
begin
    select count(*) into total
    from crew_members
    where license_expiry > current_date;
    
    return total;
end;
$$ language plpgsql;

select count_valid_licenses() as valid_crew_count;

--Задание 2
create or replace function get_crew_by_role(member_role text)
returns table(full_name text, license_no text) as $$
begin
    return query
    select cm.full_name, cm.license_no
    from crew_members cm
    where cm.role = member_role;
end;
$$ language plpgsql;

select * from get_crew_by_role('First Officer');

--Задание 3
create or replace procedure add_seat(p_airport_code text, p_seat_no text, p_fare_conditions text)
language plpgsql as $$
begin
	insert into seats (airplane_code, seat_no, fare_conditions)
	values(p_airport_code, p_seat_no, p_fare_conditions);

	exception
	when unique_violation then
		raise notice 'Ошибка: Такое место уже существует!';
	when foreign_key_violation then
		raise notice 'Ошибка: Такого самолета не существует!';
end;
$$;

call add_seat('32N', '9Z', 'Economy');

call add_seat('32N', '9Z', 'Economy');

call add_seat('XXX', '1A', 'Business');

--Упражнение 4 – Использование временных таблиц
--Задание 1
--Создаём временную табличечку
begin;
create temp table temp_crew_workload on commit delete rows as
select cm.crew_id, cm.full_name, cm.role, count(fc.flight_id) as flights_count
from crew_members cm
left join flight_crew fc on cm.crew_id = fc.crew_id
group by cm.crew_id, cm.full_name, cm.role;

--Задание 2
create index idx_temp_workload_count on temp_crew_workload(flights_count);

analyze temp_crew_workload;

--Задание 3
select * from temp_crew_workload
order by flights_count desc, full_name asc
limit 5;

--Задание 4
insert into temp_crew_workload (crew_id, full_name, role, flights_count)
values (43, 'Тест Высокий', 'Flight Attendant', 0);

select * from temp_crew_workload where crew_id = 43;

--Задание 5
commit;

select * from temp_crew_workload;





