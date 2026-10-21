--Лабораторная №1
--Выполнил: Михайлов АО гр. 4313

--Упражнение 1 - Извлечение данных
--Задание 2
select * from seats;
--Задание 3
select * from seats
order by airplane_code asc, seat_no desc;
--Задание 4
select COUNT(*) from seats;
--Задание 5
select COUNT(*) from seats
where airplane_code = '32N';
--Задание 6
select airplane_code from seats
where seat_no in ('30C', '51G');

--Упражнение 2 - Модификация изображения извлечённых данных
--Задание 1
select distinct airplane_code from seats;
--Задание 2
select airplane_code || ' ' || seat_no as airplane_seats from seats;
--Задание 3
select seat_no,
    case 
        when seat_no ~ '[A-Z]$' then SUBSTRING(seat_no, 1, LENGTH(seat_no) - 1)::integer
        else seat_no::integer 
    end as seat_number,
    case 
        when seat_no ~ '[A-Z]$' then SUBSTRING(seat_no, LENGTH(seat_no), 1)
        else NULL 
    end as seat_letter
from seats;

--Упражнение 3 - Агрегация данных
--Задание 1
select airplane_code, COUNT(seat_no) as seat_count from seats
group by airplane_code;
--Задание 2
select airplane_code, COUNT(seat_no) as seat_count from seats
group by airplane_code having COUNT(seat_no) > 160;
--Задание 3
select airplane_code, COUNT(seat_no) as seat_count, 'more than 160'from seats
group by airplane_code having COUNT(seat_no) > 160
union 
select airplane_code, COUNT(seat_no) as seat_count, '160 or less' from seats
group by airplane_code having COUNT(seat_no) <= 160;
--Задание 4
select airplane_code, COUNT(seat_no) as seat_count from seats
group by rollup(airplane_code);
--Задание 5
select 
    case 
        when GROUPING(airplane_code) = 1 then 'ALL'
        else airplane_code 
    end as airplane_code,
    COUNT(*) as seat_count
from seats
group by rollup(airplane_code);

--Упражнение 4 - Модификация данных в таблице
--Задание 1
delete from seats
where airplane_code = '32N';
--Задание 2
update seats
set airplane_code = '32N'
where airplane_code = '339';
--Задание 3
insert into seats (seat_no, airplane_code, fare_conditions)
values  
    ('1A', '339', 'Business'),
    ('1B', '339', 'Business'),
    ('1C', '339', 'Business');

--Упражнение 5 - Запросы к нескольким таблицам
--Задание 1
select * from flights limit 10;
select * from airplanes limit 10;
select * from routes limit 10;
--Задание 2
--INNER JOIN
select COUNT(*) from flights f
inner join routes r on f.route_no = r.route_no
inner join airplanes a on r.airplane_code = a.airplane_code;
--LEFT JOIN
select COUNT(*) from flights f
left join routes r on f.route_no = r.route_no
left join airplanes a on r.airplane_code = a.airplane_code;
--RIGHT JOIN
select COUNT(*) from flights f
right join routes r on f.route_no = r.route_no
right join airplanes a on r.airplane_code = a.airplane_code;
--Задание 3
DELETE FROM seats WHERE airplane_code = '32N';
--не повлияло на кол-во из пункта 2, тк мы не используем эту таблицу
--Задание 4 
select COUNT(*) as seat_count from seats s
join routes r on s.airplane_code = r.airplane_code
join flights f on r.route_no = f.route_no
where f.scheduled_departure::time between '19:00:00' and '21:00:00' and s.airplane_code = 'E70';
--Задание 5
select MAX(f.scheduled_departure) as latest_monday_departure from flights f
join routes r on f.route_no = r.route_no
where ARRAY_POSITION(r.days_of_week, 1) is not NULL;



