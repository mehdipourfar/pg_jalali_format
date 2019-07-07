-- Inspired by python-jalali

CREATE OR REPLACE FUNCTION format_jalali(DATE)
    RETURNS TEXT
    AS $$
DECLARE
    d alias FOR $1;
    i INTEGER;
    gy INT;
    gm INT;
    gd INT;
    jy INT;
    jm INT;
    jd INT;
    g_day_no INT;
    j_day_no INT;
    g_days_in_month INTEGER[] := ARRAY[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    j_days_in_month INTEGER[] := ARRAY[31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    j_np INT;
BEGIN
    gy := date_part('year', d) - 1600;
    gm := date_part('month', d) - 1;
    gd := date_part('day', d) - 1;
    g_day_no = 365 * gy + (gy + 3) / 4 - (gy + 99) / 100 + (gy + 399) / 400;
    FOR i IN 1..gm LOOP
        g_day_no := g_day_no + g_days_in_month[i];
    END LOOP;
    IF gm > 1 AND ((gy % 4 = 0 AND gy % 100 != 0) OR (gy % 400 = 0)) THEN
        -- leap and after Feb
        g_day_no := g_day_no + 1;
    END IF;
    g_day_no := g_day_no + gd;
    j_day_no := g_day_no - 79;
    j_np := j_day_no / 12053;
    j_day_no := j_day_no % 12053;
    jy := 979 + 33 * j_np + 4 * (j_day_no / 1461);
    j_day_no := j_day_no % 1461;
    IF j_day_no >= 366 THEN
        jy := jy + (j_day_no - 1) / 365;
        j_day_no := (j_day_no - 1) % 365;
    END IF;
    FOR i IN 1..12 LOOP
        jm := i - 1;
        IF j_day_no < j_days_in_month[i] THEN
            jm := jm - 1;
            EXIT;
        END IF;
        j_day_no := j_day_no - j_days_in_month[i];
    END LOOP;
    jm := jm + 2;
    jd := j_day_no + 1;
    RETURN format('%s/%s/%s', jy, to_char(jm, 'FM09'), to_char(jd, 'FM09'));
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OR REPLACE FUNCTION format_jalali(
    timestamp WITH TIME ZONE,
    with_time BOOLEAN DEFAULT TRUE
)
    RETURNS TEXT
    AS $$
BEGIN
    IF with_time THEN
        RETURN format(
            '%s %s:%s:%s',
            format_jalali($1::date),
            to_char(date_part('hour', $1)::INT, 'FM09'),
            to_char(date_part('minute', $1)::INT, 'FM09'),
            to_char(date_part('second', $1)::INT, 'FM09')
        );
    ELSE
        RETURN format_jalali($1::date);
    END IF;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
