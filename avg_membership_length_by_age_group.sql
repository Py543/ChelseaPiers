select 
    case when age between 0 and 11 then '0-11'
         when age between 12 and 24 then '12-24'
         when age between 25 and 54 then '25-54'
         when age between 55 and 74 then '55-74'
         when age >= 75 then '75+'
    else '' end as age_group,
    count(*),
    avg(membership_length_in_months)::decimal(16,2)
from chelsea_cleaned
where
    age < 100 and 
    dob is not null
group by 1;