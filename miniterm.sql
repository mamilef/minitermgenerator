-- Package Specification
CREATE OR REPLACE PACKAGE miniterm_pkg AS
    TYPE predicate_array IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;
    TYPE miniterm_table IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;

    FUNCTION generate_miniterms(predicates predicate_array) RETURN miniterm_table;
END miniterm_pkg;
/
 
-- Package Body
CREATE OR REPLACE PACKAGE BODY miniterm_pkg AS
    FUNCTION generate_miniterms(predicates predicate_array) RETURN miniterm_table IS
        miniterms miniterm_table;
        v_miniterm VARCHAR2(200);
        term_index PLS_INTEGER := 1;

    BEGIN
        FOR i IN 1 .. predicates.COUNT LOOP
            v_miniterm := '';

            -- Use REGEXP_SUBSTR to split each predicate by 'AND' into individual conditions
            FOR j IN (SELECT REGEXP_SUBSTR(predicates(i), '[^ AND]+', 1, LEVEL) AS condition
                      FROM dual
                      CONNECT BY REGEXP_SUBSTR(predicates(i), '[^ AND]+', 1, LEVEL) IS NOT NULL) LOOP
                          
                v_miniterm := v_miniterm || TRIM(j.condition) || ' | ';  -- Combine conditions with a separator
            END LOOP;

            -- Remove the trailing separator and add to the miniterm list
            v_miniterm := RTRIM(v_miniterm, ' | ');
            miniterms(term_index) := v_miniterm;
            term_index := term_index + 1;
        END LOOP;

        RETURN miniterms;
    END generate_miniterms;
END miniterm_pkg;
/

-- Example Usage Script
DECLARE
    predicates miniterm_pkg.predicate_array;
    miniterm_list miniterm_pkg.miniterm_table;
BEGIN
    -- Sample predicates
    predicates(1) := 'A=1 AND B=0';
    predicates(2) := 'A=0 AND C=1';
    predicates(3) := 'B=1 AND C=0';
    
    -- Generate miniterms
    miniterm_list := miniterm_pkg.generate_miniterms(predicates);
    
    -- Display the generated miniterms
    FOR i IN 1 .. miniterm_list.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(miniterm_list(i));
    END LOOP;
END;
/
