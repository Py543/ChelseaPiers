-- Raw tablew for import
create table chelsea(
    Member_ID text,
    Monthly_Rate text,
    Join_Date date,
    Cancel_Date date,
    Zip_Code text,
    Personal_Training_Client text,
    Check_ins_per_Week text,
    DOB text
);

create table chelsea_cleaned(
    Member_ID text,
    Monthly_Rate float,
    Join_Date date,
    Cancel_Date date,
    Zip_Code bigint,
    Personal_Training_Client boolean,
    Check_ins_per_Week bigint,
    DOB date,
    age int,
    membership_length_in_months int
);


insert into chelsea_cleaned (
    select 
        Member_ID,
        replace(Monthly_Rate, '$', '')::float as monthly_rate,
        Join_Date ,
        Cancel_Date ,
        case
            when Zip_Code not ilike 'error' then zip_code::int
        else null end as zipcode ,
        Personal_Training_Client::boolean ,
        Check_ins_per_Week::int ,
        case
            when dob ilike '-' then null
        else dob::date end as dob,
        case when dob not ilike '-' then extract(year from age(dob::date))::int else null end as age,
        case when cancel_date is not null
            then extract(year from age(cancel_date, join_date)) * 12 + extract(month from age(cancel_date, join_date))
            else extract(year from age(current_date, join_date)) * 12 + extract(month from age(current_date, join_date))
        end as membership_length_in_months
    from chelsea 
); 