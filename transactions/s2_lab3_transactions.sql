--Лабораторная №3
--Выполнил: Михайлов АО гр. 4313
--Сессия 2

--Упражнение 1 - Управление транзакциями и блокировками. Разработка триггеров
begin;
update crew_members 
set role = 'First Officer' 
where crew_id = (select min(crew_id) from crew_members);
commit;

--Упражнение 2 – Транзакции с уровнем изоляции REPEATABLE READ
begin;
update crew_members 
set role = 'Captain' 
where crew_id = (select min(crew_id) from crew_members);
commit;

--Упражнение 3 - Транзакции с уровнем изоляции SERIALIZABLE
begin isolation level serializable;
select count(*) from crew_members
where role = 'Flight Attendant';

insert into crew_members (full_name , role, license_no, license_expiry, phone)
values ('Ширинкин Жлеб', 'Flight Attendant', 'LIS_SER_18', '2026-01-01', '+79217158974');

commit;

--Упражнение 4 – Транзакции с использованием lock_timeout
begin;
set local lock_timeout = '10s';

update crew_members
set phone = '+67777777777'
where crew_id = (select min(crew_id) from crew_members);