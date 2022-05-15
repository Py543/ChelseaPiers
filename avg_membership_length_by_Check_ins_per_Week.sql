select 
    Check_ins_per_Week,
    avg(membership_length_in_months)::decimal(16,2)
from chelsea_cleaned
where
    age < 100 and 
    dob is not null 
group by 1;