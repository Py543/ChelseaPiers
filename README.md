# Solutions

The below analysis addresses how retention, average membership length, and the life-time value of membership are impacted by:
- Age
- Personal Training Participation

## Peocedure
- CSV file with member data was loaded into a PostgreSQL table.
- This table was cleaned to remove outliers/missing data and data formats were corrected.
- All queries were then executed against this cleaned dataset.
- The results of these queries were exporoted to excel to create vizualizations against each of them.

## Formulas
### Retention
```retention = ((MB + NM - ML) - NM) / MB```
- MB: Members before time period 
- NM: New members added during time period
- ML: Members lost during time period
- Time Period: predefined duration for which we're calculating retention.
- Formula source: [Higher Logic Blog](https://www.higherlogic.com/blog/how-to-calculate-your-member-retention-rate/)

### Life-Time Value
```LTV = Average Membership Length * Average Monthly Rate```
- Formula source: [HubSpot Blog](https://blog.hubspot.com/service/how-to-calculate-customer-lifetime-value)

## Directory Structure
- Each query that was run as part of the analysis is included in this directory as a `.sql` file. 
- Table creation and data cleaning queries are in the `setup.sql` file.
- the `data/` director contains results of each of these queries in a csv file with the same name.