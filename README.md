# Postgres functions for formatting date or timestamp as Jalali date
Useful when you want to export your data directly from postgres.

# Installation
```
    psql -f format_jalali.sql
```

# Examples
```
SELECT format_jalali('2019-07-07 14:10:52.84937+04:30') -- 1398/04/16 14:10:53
SELECT format_jalali('2019-07-07 14:10:52.84937+04:30', false) -- 1398/04/16
SELECT format_jalali('2019-07-07 14:10:52.84937+04:30'::date) -- 1398/04/16
```
