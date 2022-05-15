/*
Retention Formula: ((MB + NM - ML) - NM) / MB 
    MB: Members before time period 
    NM: New members added during time period
    ML: Members lost during time period
    Time Period: predefined duration for which we're calculating retention.

LTV Formula: Average Membership Length * Average Monthly Rate
*/
with 
dataset as (
    select 
        *,
        case when age between 0 and 11 then '0-11'
             when age between 12 and 24 then '12-24'
             when age between 25 and 54 then '25-54'
             when age between 55 and 74 then '55-74'
             when age >= 75 then '75+'
        else '' end as age_group
    from chelsea_cleaned
    where
        age < 100 and 
        dob is not null
),

members_before as (
    select 
        age_group,
        count(*) as members_before_tp 
    from dataset
    where
        join_date < '2015-01-01' 
    group by 1
),


members_added_during_period as (
    select 
        age_group,
        count(*) as members_added_during 
    from dataset
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31' 
        group by 1
),

lost_during_tp as (
    select 
        age_group,
        count(*) as lost_members 
    from dataset
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31' and 
        cancel_date >= '2015-01-01' and 
        cancel_date <= '2018-12-31'
        group by 1
),

retention_by_group as (
    select
        mb.age_group,
        ((mb.members_before_tp + ma.members_added_during - ld.lost_members) - ma.members_added_during)::float/mb.members_before_tp as retention
    from 
        members_before as mb 
        join members_added_during_period as ma on mb.age_group = ma.age_group
        join lost_during_tp as ld on ma.age_group = ld.age_group
),

average_rate as (
 select 
    age_group,
    avg(monthly_rate) as avg_monthly_rate
from dataset
where 
    join_date >= '2015-01-01' and 
    join_date <= '2018-12-31' 
group by 1
),

avg_mem_length as (
    select 
        age_group,
        avg(membership_length_in_months) as length
    from dataset
    group by 1
)


select 
    average_rate.age_group,
    (length * avg_monthly_rate)::decimal(16,2) as ltv
from retention_by_group
join average_rate on average_rate.age_group = retention_by_group.age_group
join avg_mem_length on avg_mem_length.age_group = retention_by_group.age_group
;
