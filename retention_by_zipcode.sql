with 
dataset as (
    select
        *
    from chelsea_age_buckets
    where
        age < 100 and 
        dob is not null and 
        zip_code is not null
),

/*
Retention Formula: ((MB + NM - ML) - NM) / MB 
    MB: Members before time period 
    NM: New members added during time period
    ML: Members lost during time period
    Time Period: predefined duration for which we're calculating retention.
*/
members_before as (
    select 
        zip_code,
        count(*) as members_before_tp 
    from dataset
    where
        join_date < '2015-01-01'
    group by 1
),


members_added_during_period as (
    select 
        zip_code,
        count(*) as members_added_during 
    from dataset
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31'
        group by 1
),

lost_during_tp as (
    select 
        zip_code,
        count(*) as lost_members 
    from dataset
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31' and 
        cancel_date >= '2015-01-01' and 
        cancel_date <= '2018-12-31'
        group by 1
)

select
    mb.zip_code,
    ((((mb.members_before_tp + ma.members_added_during - ld.lost_members) - ma.members_added_during)::float/mb.members_before_tp)*100)::decimal(16,2)
from 
    members_before as mb 
    join members_added_during_period as ma on mb.zip_code = ma.zip_code
    join lost_during_tp as ld on ma.zip_code = ld.zip_code
