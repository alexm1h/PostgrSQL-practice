--Лабораторная №2
--Выполнил: Михайлов АО гр. 4313

--Упражнение 1 - Получение данных об имеющихся ограничениях
--Задание 1
select column_name, data_type, is_nullable, column_default 
from information_schema.columns c
where table_name = 'flights';
--Задание 2
insert into flights (route_no, status, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival)
values ('PG9999', 'Scheduled', '2025-12-01 10:00:00', null, '2025-12-01 10:00:00', '2025-12-02 10:00:00');
--Получили ошибку, что нельзя писать null в scheduled_arrival
--Так как на нём стоит ограничение. Для добавления строки это поле обязательно к заполнению

--Упражнение 2 - Создание таблиц с внутренними и внешними ограничениями
--Задание 1
create table crew_members (
	crew_id serial primary key,
	full_name text not null,
	role text not null check (role in ('Captain', 'First Officer', 'Flight Engineer', 'Flight Attendant')),
	license_no text not null unique,
	license_expiry date not null check (license_expiry > '2025-01-01')
);
--Задание 2
create table flight_crew (
	crew_id integer not null references crew_members(crew_id) on delete cascade,
	flight_id integer not null references flights(flight_id) on delete restrict,
	assigned_role text not null check (assigned_role in ('Captain', 'First Officer', 'Flight Engineer', 'Flight Attendant')),
	constraint pk_flight_crew primary key (crew_id, flight_id)
);
--Задание 3
create table lounge_visits (
	visit_id serial primary key,
	passenger_id text not null,
	airport_code char(3) not null references airports_data(airport_code) on delete cascade,
	flight_id integer references flights(flight_id) on delete set null,
	visit_time timestamptz not null default now() check (visit_time > '2025-01-01')
);	
--Задание 4
--Заполняем все таблицы новые
insert into crew_members (full_name, role, license_no, license_expiry)
values 
    ('Михайлов Александр', 'Captain', 'LIC001', '2026-01-01'),
    ('Рагушин Игорь', 'First Officer', 'LIC002', '2026-02-01'),
    ('Саночкин Ростислав', 'Flight Engineer', 'LIC003', '2026-03-01'),
    ('Чернявский Никита', 'Flight Attendant', 'LIC004', '2026-04-01'),
    ('Суханов Максим', 'Captain', 'LIC005', '2026-05-01'),
    ('Дроздов Сергей', 'First Officer', 'LIC006', '2026-06-01'),
    ('Новиков Александр', 'Flight Engineer', 'LIC007', '2026-07-01'),
    ('Бабкина Алина', 'Flight Attendant', 'LIC008', '2026-08-01'),
    ('Комаров Артём', 'Captain', 'LIC009', '2026-09-01'),
    ('Жуао Вальдемиру', 'First Officer', 'LIC010', '2026-10-01'),
    ('Фролов Илья', 'Flight Engineer', 'LIC011', '2026-11-01'),
    ('Фролов Павел', 'Flight Attendant', 'LIC012', '2026-12-01'),
    ('Киррилюк Дина', 'Captain', 'LIC013', '2027-01-01'),
    ('Шарапов Глеб', 'First Officer', 'LIC014', '2027-02-01'),
    ('Киррилюк Алина', 'Flight Engineer', 'LIC015', '2027-03-01');

insert into flight_crew (crew_id, flight_id, assigned_role)
values 
    (1, 1, 'Captain'),
    (2, 1, 'First Officer'),
    (3, 1, 'Flight Engineer'),
    (4, 1, 'Flight Attendant'),
    (5, 2, 'Captain'),
    (6, 2, 'First Officer'),
    (7, 2, 'Flight Engineer'),
    (8, 2, 'Flight Attendant'),
    (9, 3, 'Captain'),
    (10, 3, 'First Officer'),
    (11, 3, 'Flight Engineer'),
    (12, 3, 'Flight Attendant'),
    (13, 4, 'Captain'),
    (14, 4, 'First Officer'),
    (15, 4, 'Flight Engineer');

insert into lounge_visits (passenger_id, airport_code, flight_id, visit_time)
values 
    ('PAX001', 'SVO', 1, '2025-06-01 10:00:00'),
    ('PAX002', 'LED', 2, '2025-06-02 11:00:00'),
    ('PAX003', 'KJA', 3, '2025-06-03 12:00:00'),
    ('PAX004', 'DME', 4, '2025-06-04 13:00:00'),
    ('PAX005', 'VVO', 5, '2025-06-05 14:00:00'),
    ('PAX006', 'SVO', 6, '2025-06-06 15:00:00'),
    ('PAX007', 'LED', 7, '2025-06-07 16:00:00'),
    ('PAX008', 'KJA', 8, '2025-06-08 17:00:00'),
    ('PAX009', 'DME', 9, '2025-06-09 18:00:00'),
    ('PAX010', 'VVO', 10, '2025-06-10 19:00:00'),
    ('PAX011', 'SVO', 11, '2025-06-11 20:00:00'),
    ('PAX012', 'LED', 12, '2025-06-12 21:00:00'),
    ('PAX013', 'KJA', 13, '2025-06-13 22:00:00'),
    ('PAX014', 'DME', 14, '2025-06-14 23:00:00'),
    ('PAX015', 'VVO', 15, '2025-06-15 09:00:00');

--Упражнение 3 - проверка работы ограничений
--Задание 1
insert into crew_members (full_name, role, license_no, license_expiry, phone)
values ('Попович Алексей', 'Pilot', 'LIC016', '2026-01-01', '+79998887766');
insert into crew_members (full_name, role, license_no, license_expiry, phone)
values ('Груздь Дмитрий', 'Captain', 'LIC121', '2024-01-01', '+79998887766');
--Задание 2
insert into crew_members (full_name, role, license_no, license_expiry, phone)
values ('Тестов Тестостеронович', 'Captain', 'LIC001', '2026-01-01', '+79998887766');
--Задание 3
insert into crew_members (full_name, role, license_no, license_expiry, phone)
values ('Дубликатович Дубликат', 'Captain', 'LIC150', '2026-01-01', '+79998887766');

select crew_id from crew_members where license_no = 'LIC150';

insert into flight_crew (crew_id, flight_id, assigned_role)
values (29, 1, 'Captain');

select * from flight_crew where crew_id = 29;

delete from crew_members where crew_id = 29;

select * from flight_crew where crew_id = 29;
--Задание 4
select * from flight_crew limit 5;

delete from flights where flight_id = 1;

delete from flight_crew where flight_id = 1;

delete from flights where flight_id = 1;
--Задание 5
insert into flights (route_no, status, scheduled_departure, scheduled_arrival)
values ('PG9999', 'Scheduled', '2025-12-01 10:00:00', '2025-12-01 12:00:00');

select flight_id from flights where route_no = 'PG9999' order by flight_id desc limit 1;

insert into lounge_visits (passenger_id, airport_code, flight_id, visit_time)
values ('PAX999', 'SVO', 21762, '2025-06-01 10:00:00');

select * from lounge_visits where passenger_id = 'PAX999';

delete from flights where flight_id = 21762;

select * from lounge_visits where passenger_id = 'PAX999';

--Упражнение 4 – Добавление и управление ограничениями в существующих таблицах
--Задание 1
alter table crew_members
add column phone text;
--Задание 2
update crew_members
set phone = '+79998887766'
where phone is null;
--Задание 3
alter table crew_members
alter column phone set not null;
alter table crew_members
add constraint chk_phone_format check (phone like '+_%');
--Задание 4
select conname, contype, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'crew_members'::regclass;
--Задание 5
alter table crew_members
drop constraint chk_phone_format;

alter table crew_members 
add constraint chk_phone_format check (phone ~ '\+[1-9][0-9]{10}$')

select conname, contype, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'crew_members'::regclass;


