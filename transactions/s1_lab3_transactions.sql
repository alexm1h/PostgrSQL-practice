--Лабораторная №3
--Выполнил: Михайлов АО гр. 4313
--Сессия 1

--Упражнение 1 - Управление транзакциями и блокировками. Разработка триггеров
begin;
select crew_id, full_name, role from crew_members
where crew_id = (select min(crew_id) from crew_members);

commit;

--Упражнение 2 – Транзакции с уровнем изоляции REPEATABLE READ
begin isolation level repeatable read;
select crew_id, full_name, role from crew_members
where crew_id=(select min(crew_id) from crew_members)

commit;

--Упражнение 3 - Транзакции с уровнем изоляции SERIALIZABLE
begin isolation level serializable;
select count(*) from crew_members
where role = 'Flight Attendant';

insert into crew_members (full_name , role, license_no, license_expiry, phone)
values ('Шарашкин Хлеб', 'Flight Attendant', 'LIS_SER_17', '2026-01-01', '+79217958923');

commit;

--Упражнение 4 – Транзакции с использованием lock_timeout
begin;
select full_name 
from crew_members 
where crew_id = (select min(crew_id) from crew_members)
for update;

rollback;

--Упражнение 5 – Использование триггеров для логирования изменений в таблице
create table crew_audit (
    audit_id serial primary key,
    crew_id integer,
    action text not null check (action in ('INSERT', 'UPDATE', 'DELETE')),
    changed_by text not null default current_user,
    changed_at timestamptz not null default now(),
    old_data jsonb,
    new_data jsonb
);

create or replace function log_crew_changes()
returns trigger as $$
begin
	if (TG_OP = 'INSERT') then
		insert into crew_audit (crew_id, action, new_data)
		values (new.crew_id, 'INSERT', to_jsonb(new));
		return new;
	elsif (TG_OP = 'UPDATE') then
		insert into crew_audit (crew_id, action, old_data, new_data)
		values (new.crew_id, 'UPDATE', to_jsonb(old), to_jsonb(new));
		return new;
	elsif (TG_OP = 'DELETE') then
        insert into crew_audit (crew_id, action, old_data)
        values (old.crew_id, 'DELETE', to_jsonb(old));
        return old;
	end if;
	return null;
end;
$$ language plpgsql;

create trigger trg_crew_audit
after insert or update or delete on crew_members
for each row execute function log_crew_changes();

insert into crew_members (full_name, role, license_no, license_expiry, phone)
values ('Тестовый Триггер', 'Captain', 'LIC_TRIGGER1', '2026-01-01', '+79217458923');

update crew_members 
set role = 'First Officer' 
where license_no = 'LIC_TRIGGER1';

delete from crew_members 
where license_no = 'LIC_TRIGGER1';

select * from crew_audit order by audit_id;

--Упражнение 6 – Использование запрещающих триггеров
create or replace function prevent_captain_delete()
returns trigger as $$
begin
    if (old.role = 'Captain' and exists (select 1 from flight_crew where crew_id = old.crew_id)) then
        raise exception 'Нельзя оставлять рейс без капитана';
    end if;
    return old;
end;
$$ language plpgsql;

create trigger trg_prevent_captain_delete
before delete on crew_members
for each row execute function prevent_captain_delete();

select cm.crew_id, cm.full_name, cm.role, fc.flight_id from crew_members cm
join flight_crew fc on cm.crew_id = fc.crew_id
where cm.role = 'Captain'
limit 1;

delete from crew_members where crew_id = 5;

delete from flight_crew where crew_id = 5;

delete from crew_members where crew_id = 5;
