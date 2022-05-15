with 
dataset as (
    select *
    from chelsea_cleaned
    where
        age < 100 and 
        dob is not null
),
/*
Retention Formula: ((MB + NM - ML) - NM) / MB 
    MB: Members before time period 
    NM: New members added during time period
    ML: Members lost during time period
    Time Period: predefined duration for which we're calculating retention.
*/

with members_before as (
    select 
        Personal_Training_Client,
        count(*) as members_before_tp 
    from chelsea_cleaned
    where
        join_date < '2015-01-01'
    group by 1
),


members_added_during_period as (
    select 
        Personal_Training_Client,
        count(*) as members_added_during 
    from chelsea_cleaned
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31'
        group by 1
),

lost_during_tp as (
    select 
        Personal_Training_Client,
        count(*) as lost_members 
    from chelsea_cleaned
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31' and 
        cancel_date >= '2015-01-01' and 
        cancel_date <= '2018-12-31'
        group by 1
)

select
    mb.Personal_Training_Client,
    (((mb.members_before_tp + ma.members_added_during - ld.lost_members) - ma.members_added_during)::float/mb.members_before_tp)*100
from 
    members_before as mb join
    members_added_during_period ma on mb.Personal_Training_Client = ma.Personal_Training_Client join
    lost_during_tp ld on ma.Personal_Training_Client = ld.Personal_Training_Client
