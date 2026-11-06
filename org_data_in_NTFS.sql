--Лабораторная работа номер 5
--Выполнил: Михайлов Александр, группа 4313

--Упражнение 1 – Управление хранением данных базы данных
-- Задание 1
show data_directory;

--Задание 2
select pg_relation_filepath('crew_members');

--Задание 3
create tablespace lab5_space location 'C:/pg_tablespace';

--Задание 4
alter table crew_members set tablespace lab5_space;

--Упражнение 2 – Работа с журналом транзакций
--Задание 1
select pid, usename, state, query, backend_type from pg_stat_activity
where state is not null;

--Задание 2
select * from pg_ls_waldir();

--Задание 3
show checkpoint_timeout;

--Задание 4
show archive_mode;

--Задание 5
show archive_command;

--Упражнение 3 – Резервное копирование
--Создали копию базы данных demo и поместили её в demo2 через консоль
--Задание 5
truncate table seats;

select * from seats;
