select * from emergency_calls limit 100;
select * from moon_phase limit 100;

create view moon.moon_calls as (
select y.*, mp.moon_phase
from (
	select timestamp_hr
	, count(case when type = 'EMS' then 1 else null end) as ems
	, count(case when type = 'Fire' then 1 else null end) as fire
	, count(case when type = 'Traffic' then 1 else null end) as traffic
	from (
		select *, CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d %H'), ':00:00') AS DATETIME) as timestamp_hr
		from emergency_calls
		) x
	group by 1 ) y
left join moon_phase mp on CAST(CONCAT(DATE_FORMAT(y.timestamp_hr, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) = mp.moon_date);

alter view moon.moon_calls2 as (
select y.*, mp.moon_phase
from (
	select timestamp_hr
	, count(case when sub_type = 'ABDOMINAL PAINS' then 1 else null end) as 'ABDOMINAL PAINS'
	, count(case when sub_type = 'ALTERED MENTAL STATUS' then 1 else null end) as 'ALTERED MENTAL STATUS'
	, count(case when sub_type = 'ANIMAL BITE' then 1 else null end) as 'ANIMAL BITE'
    , count(case when sub_type = 'CARDIAC ARREST' then 1 else null end) as 'CARDIAC ARREST'
    , count(case when sub_type = 'CARDIAC EMERGENCY' then 1 else null end) as 'CARDIAC EMERGENCY'
    , count(case when sub_type = 'DEHYDRATION' then 1 else null end) as 'DEHYDRATION'
    , count(case when sub_type = 'DIZZINESS' then 1 else null end) as 'DIZZINESS'
    , count(case when sub_type = 'FALL VICTIM' then 1 else null end) as 'FALL VICTIM'
    , count(case when sub_type = 'FEVER' then 1 else null end) as 'FEVER'
    , count(case when sub_type = 'FRACTURE' then 1 else null end) as 'FRACTURE'
    , count(case when sub_type = 'HEAD INJURY' then 1 else null end) as 'HEAD INJURY'
    , count(case when sub_type = 'LACERATIONS' then 1 else null end) as 'LACERATIONS'
    , count(case when sub_type = 'NAUSEA/VOMITING' then 1 else null end) as 'NAUSEA/VOMITING'
    , count(case when sub_type = 'OVERDOSE' then 1 else null end) as 'OVERDOSE'
    , count(case when sub_type = 'RESPIRATORY EMERGENCY' then 1 else null end) as 'RESPIRATORY EMERGENCY'
    , count(case when sub_type = 'SEIZURES' then 1 else null end) as 'SEIZURES'
    , count(case when sub_type = 'SYNCOPAL EPISODE' then 1 else null end) as 'SYNCOPAL EPISODE'
    , count(case when sub_type = 'UNCONSCIOUS SUBJECT' then 1 else null end) as 'UNCONSCIOUS SUBJECT'
	from (
		select *, CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d %H'), ':00:00') AS DATETIME) as timestamp_hr
		from emergency_calls
		) x
	group by 1 ) y
left join moon_phase mp on CAST(CONCAT(DATE_FORMAT(y.timestamp_hr, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) = mp.moon_date);

select * from moon_calls limit 100;
select * from moon_calls2 limit 100;


set @first_date = (select min(days) from (
select CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) as days
from emergency_calls
group by days) x);
	
create function get_first_date() returns datetime
	return select min(days) from (
select CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) as days
from emergency_calls
group by days) x;

select @first_date;

alter view moon.night_moon_calls as (
select day_number, calldate, daily_calls, mp.moon_phase
from (
	select datediff(CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d'), ' 00:00:00') AS DATETIME), cast('2015-12-10 00:00:00' as datetime)) as day_number
    , CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) as day_date
	from emergency_calls
	group by day_number, day_date
	order by day_number asc) dn
left join (select CAST(CONCAT(DATE_FORMAT(timestamp, '%Y-%m-%d'), ' 00:00:00') AS DATETIME) as calldate
	, count(*) as daily_calls
	from emergency_calls
	where hour(timestamp) < 3
	or hour(timestamp) >= 19
	group by calldate) calls on calls.calldate between dn.day_date and date_add(dn.day_date, interval '180' day)
left join moon_phase mp on calls.calldate = mp.moon_date
)
;

select count(*) from moon.night_moon_calls;
