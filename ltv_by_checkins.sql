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
        *
    from chelsea_cleaned
    where
        age < 100 and 
        dob is not null
),

members_before as (
    select 
        Check_ins_per_Week,
        count(*) as members_before_tp 
    from dataset
    where
        join_date < '2015-01-01' 
    group by 1
),


members_added_during_period as (
    select 
        Check_ins_per_Week,
        count(*) as members_added_during 
    from dataset
    where
        join_date >= '2015-01-01' and 
        join_date <= '2018-12-31' 
        group by 1
),

lost_during_tp as (
    select 
        Check_ins_per_Week,
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
        mb.Check_ins_per_Week,
        ((mb.members_before_tp + ma.members_added_during - ld.lost_members) - ma.members_added_during)::float/mb.members_before_tp as retention
    from 
        members_before as mb 
        join members_added_during_period as ma on mb.Check_ins_per_Week = ma.Check_ins_per_Week
        join lost_during_tp as ld on ma.Check_ins_per_Week = ld.Check_ins_per_Week
),

average_rate as (
 select 
    Check_ins_per_Week,
    avg(monthly_rate) as avg_monthly_rate
from dataset
where 
    join_date >= '2015-01-01' and 
    join_date <= '2018-12-31' 
group by 1
),

avg_mem_length as (
    select 
        Check_ins_per_Week,
        avg(membership_length_in_months) as length
    from dataset
    group by 1
)


select 
    average_rate.Check_ins_per_Week,
    (length * avg_monthly_rate)::decimal(16,2) as ltv
from retention_by_group
join average_rate on average_rate.Check_ins_per_Week = retention_by_group.Check_ins_per_Week
join avg_mem_length on avg_mem_length.Check_ins_per_Week = retention_by_group.Check_ins_per_Week
;
