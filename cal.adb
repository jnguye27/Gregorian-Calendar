-- Program: PRINTING A CALENDAR
-- Creator: Jessica Nguyen
-- Date: 2024-02-19
-- Purpose: Prints out a calendar for a given year in the Gregorian calendar

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.IO_Exceptions;

-- the main function
procedure cal is 
    -- declaring variables
    year : integer; 
    firstday : integer;
    lang : integer;
    indent : integer;

    -- declaring a 2D calendar array: rows = 6 weeks x 4 months, columns = 7 days x 3 months
    type calendartype is array (0..23, 0..20) of integer;
    calendar : calendartype;

    -- boolean function that returns true if the year is legal (within the Gregorian calendar) and false otherwise
    function isvalid (year : in integer) return boolean is
    begin
        if (year >= 1582) and (year <= 9999) then
            return true;
        else
            return false;
        end if;
    end isvalid;
    
    -- integer procedure that reads the year from the user, and returns the year, day of January 1st, preferred language, and indent
    procedure readcalinfo (year : out integer; firstday : out integer; lang : out integer; indent : out integer) is
        input : integer;
        y : integer;
    begin
        loop
            -- all exceptions in this subprogram fixes char inputs for integer variables
            begin
                -- ask the user to input a year
                new_line;
                put ("Enter a year (1582 - 9999): ");
                get (input);

                -- check if the year is valid
                if isvalid(input) then
                    -- returns the year
                    year := input;

                    -- returns the first day of January
                    y := input - 1;
                    firstday := (36 + y + (y/4) - (y/100) + (y/400)) mod 7;

                    -- returns the language
                    loop
                        begin
                            new_line;
                            put ("Enter a language (1 = English, 2 = French): ");
                            get (input);

                            -- check if the language is valid
                            if (input = 1) or (input = 2) then
                                lang := input;
                                
                                -- returns the indent number
                                loop
                                    begin
                                        new_line;
                                        put ("Enter the number of indents before the banner is displayed: ");
                                        get (input);

                                        -- check if the indent value is valid
                                        if (input >= 0) then
                                            indent := input;
                                            exit;
                                        else
                                            new_line;
                                            put ("Invalid out-of-range input, please try again.");
                                        end if; 
                                    exception
                                        when ADA.IO_EXCEPTIONS.DATA_ERROR => 
                                            new_line; 
                                            put ("Invalid non-numeric input, please try again.");
                                            skip_line;
                                    end;
                                end loop;
                                exit;
                            else
                                new_line;
                                put ("Invalid out-of-range input, please try again.");
                            end if;
                        exception
                            when ADA.IO_EXCEPTIONS.DATA_ERROR => 
                                new_line; 
                                put ("Invalid non-numeric input, please try again.");
                                skip_line;
                        end;
                    end loop;
                    new_line;
                    exit;
                else
                    new_line;
                    put ("Invalid out-of-range input, please try again.");
                end if;
            exception
                when ADA.IO_EXCEPTIONS.DATA_ERROR => 
                    new_line; 
                    put ("Invalid non-numeric input, please try again.");
                    skip_line;
            end;
        end loop;
    end readcalinfo;

    -- boolean function that returns true if the year is a leap year, and false otherwise
    function leapyear (year : in integer) return boolean is
    begin
        if (year mod 4 = 0 and year mod 100 /= 0) or (year mod 400 = 0) then
            return true;
        else
            return false;
        end if;
    end leapyear;

    -- integer function that returns the number of days in a given month, in a given year
    function numdaysinmonth (month : in integer; year : in integer) return integer is
    begin
        -- is it the month of February?
        if (month = 2) then
            -- is it a leap year?
            if leapyear(year) then
                return 29;
            else
                return 28;
            end if;
        elsif (month = 4) or (month = 6) or (month = 9) or (month = 11) then
            return 30;
        else
            return 31;
        end if;
    end numdaysinmonth;

    -- a procedure that builds the calendar
    procedure buildcalendar (year : in integer; firstday : in out integer; calendar : out calendartype) is
        -- declaring variables 
        daysleft : integer; 
        row : integer;
        col : integer;
        day : integer;
        numdays : integer;
    begin
        -- make the entire array equal to zero
        for i in 0..23 loop
            for j in 0..20 loop
                calendar (i, j) := 0;
            end loop;
        end loop;

        -- initialize row & column position values
        row := 0;
        col := 0;

        for month in 1..12 loop
            -- reset values
            numdays := numdaysinmonth (month, year);
            day := 1;
            daysleft := 0;

            -- calculate next month's position
            if (month mod 3 = 1) and (month /= 1) then
                row := row + 6;
                col := 0;
            end if;

            -- put the number of days in a month into the calendar
            for i in (0 + row)..(5 + row) loop
                for j in (0 + col)..(6 + col) loop
                    if (j = firstday + col) then
                        -- when it's the first day, start adding days to the calendar
                        calendar (i, j) := day;
                        firstday := -1;
                        day := day + 1;
                    elsif (day > 1) and (day <= numdays) then
                        -- if it's inbetween the first and last day, keep adding days to the calendar
                        calendar (i, j) := day;
                        day := day + 1;
                    elsif (day > numdays) then
                        -- if day is over the last day, count the leftover days of the last week to know the next firstday
                        daysleft := daysleft + 1;
                    else
                        calendar (i, j) := 0;
                    end if;
                end loop;

                -- if there are no more days left, exit early
                if (day > numdays) then
                    exit;
                end if;
            end loop;

            -- calculate the next month's first day
            firstday := 7 - daysleft;
            if (firstday = 7) then
                firstday := 0;
            end if;

            -- go to the next month's column
            col := col + 7;
        end loop;
    end buildcalendar;

    -- a procedure that prints the month and week heading, for a row of months
    procedure printrowheading (lang : in integer; rownumber : in integer) is
    begin
        -- prints based on english (1) or french (2)
        if (lang = 1) then
            -- prints the 3 months for the specific row
            if (rownumber = 0) then
                put ("            January                        February                          March");
            elsif (rownumber = 1) then
                put ("             April                           May                             June");
            elsif (rownumber = 2) then
                put ("             July                           August                         September");
            elsif (rownumber = 3) then
                put ("            October                        November                         December");
            end if;
            
            -- prints the week headings 
            new_line;
            put ("  Su  Mo  Tu  We  Th  Fr  Sa      Su  Mo  Tu  We  Th  Fr  Sa      Su  Mo  Tu  We  Th  Fr  Sa");
        else
            if (rownumber = 0) then
                put ("            Janvier                        Fevrier                           Mars");
            elsif (rownumber = 1) then
                put ("             Avril                           Mai                             Juin");
            elsif (rownumber = 2) then
                put ("            Juillet                          Aout                          Septembre");
            elsif (rownumber = 3) then
                put ("            Octobre                        Novembre                        Decembre");
            end if;
            
            new_line;
            put ("  Di  Lu  Ma  Me  Je  Ve  Sa      Di  Lu  Ma  Me  Je  Ve  Sa      Di  Lu  Ma  Me  Je  Ve  Sa");
        end if;
        new_line;
    end printrowheading;
    
    -- a procedure that prints the dates of the months in a row in a calendar form 
    procedure printrowmonth (calendar : in calendartype; rownumber : in integer) is
        row : integer;
    begin
        -- calculate which row to print
        row := 6 * rownumber;

        -- prints out the 3 months in the specified row, adds spaces appropriately
        for i in (0 + row)..(5 + row) loop
            for j in 0..20 loop
                if (calendar (i, j) = 0) then
                    -- replace zeros with spaces
                    put (tail (" ", 4, ' '));
                elsif (i = 5 + row) and (j = 14) and (calendar (i, j) /= 0) then
                    -- if there is a day in the 6th week, print accordingly
                    put (tail (" ", 4, ' '));
                    put (calendar (i, j), 8);
                elsif (j = 7) or (j = 14) then
                    -- if this is the last day in the week, print accordingly
                    put (calendar (i, j), 8);
                else
                    -- if this is a regular day in the week, print accordingly
                    put (calendar (i, j), 4);
                    
                    -- add an indent if it's the first week and it's inbetween months
                    if (i = 0 + row) and (j = 6 or j = 13) then
                        -- indent if there are zeros in the first week
                        if (calendar (i, j + 1) /= 1) then
                            put (tail (" ", 4, ' '));
                        else
                            put (tail (" ", 0, ' '));
                        end if;
                    end if;
                end if;
            end loop;
            new_line;
        end loop;
        new_line;
    end printrowmonth;

    -- a procedure that prints the calendar banner, i.e. year in a large “font”
    procedure banner (year : in integer; indent : in integer) is
        -- declaring variables
        indexposition : integer;
        digitsinyear : array (0..3) of integer;
        subtype rowlength is string (1..40);
        digitchars : array (1..10) of rowlength;
    begin
        -- split up the digits in the given year
        digitsinyear (0) := year / 1000;
        digitsinyear (1) := (year - (digitsinyear(0) * 1000)) / 100;
        digitsinyear (2) := (year - ((digitsinyear(0) * 1000) + (digitsinyear(1) * 100))) / 10;
        digitsinyear (3) := year - ((digitsinyear(0) * 1000) + (digitsinyear(1) * 100) + (digitsinyear(2) * 10));
        
        -- concatenate the font numbers to the 2d string array
        for i in 0..3 loop
            -- calculates the range in the string
            indexposition := i*10;

            -- implement the number into each row
            if (digitsinyear(i) = 0) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 00000    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "00   00   ";
                digitchars (10)(1 + indexposition..10 + indexposition) := " 00000    ";
            elsif (digitsinyear(i) = 1) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 111      ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "1111      ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "  11      ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "111111    ";
            elsif (digitsinyear(i) = 2) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 22222    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "22   22   ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "     22   ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "     22   ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "    22    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "  22      ";
                digitchars (7)(1 + indexposition..10 + indexposition) := " 22       ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "22        ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "22        ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "2222222   ";
            elsif (digitsinyear(i) = 3) then
                digitchars (1)(1 + indexposition..10 + indexposition) := "33333     ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (5)(1 + indexposition..10 + indexposition) := " 33333    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := " 33333    ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "    33    ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "33333     ";
            elsif (digitsinyear(i) = 4) then
                digitchars (1)(1 + indexposition..10 + indexposition) := "44  44    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "44  44    ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "44  44    ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "44  44    ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "444444    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "    44    ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "    44    ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "    44    ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "    44    ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "    44    ";
            elsif (digitsinyear(i) = 5) then
                digitchars (1)(1 + indexposition..10 + indexposition) := "555555    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "55        ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "55        ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "55        ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "5555      ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "   555    ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "    55    ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "    55    ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "    55    ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "555555    ";
            elsif (digitsinyear(i) = 6) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 66666    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "66        ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "66        ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "66        ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "666666    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "66   66   ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "66   66   ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "66   66   ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "66   66   ";
                digitchars (10)(1 + indexposition..10 + indexposition) := " 66666    ";
            elsif (digitsinyear(i) = 7) then
                digitchars (1)(1 + indexposition..10 + indexposition) := "7777777   ";
                digitchars (2)(1 + indexposition..10 + indexposition) := " 777777   ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "     77   ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "    77    ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "    77    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "   77     ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "   77     ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "  77      ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "  77      ";
                digitchars (10)(1 + indexposition..10 + indexposition) := "  77      ";
            elsif (digitsinyear(i) = 8) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 88888    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (5)(1 + indexposition..10 + indexposition) := " 88888    ";
                digitchars (6)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "88   88   ";
                digitchars (10)(1 + indexposition..10 + indexposition) := " 88888    ";
            elsif (digitsinyear(i) = 9) then
                digitchars (1)(1 + indexposition..10 + indexposition) := " 99999    ";
                digitchars (2)(1 + indexposition..10 + indexposition) := "9999999   ";
                digitchars (3)(1 + indexposition..10 + indexposition) := "99   99   ";
                digitchars (4)(1 + indexposition..10 + indexposition) := "99   99   ";
                digitchars (5)(1 + indexposition..10 + indexposition) := "9999999   ";
                digitchars (6)(1 + indexposition..10 + indexposition) := " 999999   ";
                digitchars (7)(1 + indexposition..10 + indexposition) := "     99   ";
                digitchars (8)(1 + indexposition..10 + indexposition) := "     99   ";
                digitchars (9)(1 + indexposition..10 + indexposition) := "9999999   ";
                digitchars (10)(1 + indexposition..10 + indexposition) := " 99999    ";
            end if;
        end loop;

        -- the banner is displayed to stdout
        for i in 1..10 loop
            -- prints the indent
            for j in 1..indent loop
                put (" ");
            end loop;

            -- prints the string in the specified row
            put_line (digitchars(i));
        end loop;
        new_line;
        new_line;
    end banner;
begin
    -- collect user info for the year, first day of January, language, and number of indents
    readcalinfo (year, firstday, lang, indent);

    -- builds the calendar
    buildcalendar (year, firstday, calendar);

    -- displays the year in huge font
    banner (year, indent);

    -- displays the calendar
    for i in 0..3 loop
        printrowheading (lang, i);
        printrowmonth (calendar, i);
    end loop;
end cal;