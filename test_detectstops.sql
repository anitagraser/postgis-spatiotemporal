
CREATE OR REPLACE FUNCTION test.two_stops_with_gap() RETURNS void LANGUAGE 'plpgsql' 
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 0 1, 5 5 1.5, 2 2 2, 2 2 3)'),1,1) stop )
SELECT Count(stop) FROM temp INTO n0;	
IF n0 = 2
THEN RAISE INFO 'PASSED - Two stops with gap';
ELSE RAISE INFO 'FAILED - Two stops with gap';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.two_stops() RETURNS void LANGUAGE 'plpgsql' 
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 0 1, 2 2 2, 2 2 3)'),1,1) stop )
SELECT Count(stop) FROM temp INTO n0;	
IF n0 = 2
THEN RAISE INFO 'PASSED - Two stops';
ELSE RAISE INFO 'FAILED - Two stops';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.too_short() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 1 1 1, 2 2 2, 9 9 3)'),2,3) stop )
SELECT Count(stop) FROM temp INTO n0;	
IF n0 = 0
THEN RAISE INFO 'PASSED - Too short';
ELSE RAISE INFO 'FAILED - Too short';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.stop_at_end() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 2 1, 0 2 2, 0 2.1 3)'),1,1) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;	
IF t0 = 1 AND n0 = 3
THEN RAISE INFO 'PASSED - Stop at the end of the trajectory';
ELSE RAISE INFO 'FAILED - Stop at the end of the trajectory';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.stop_at_beginning() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 0 1, 0.1 0.1 2, 2 2 3)'),1,1) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;	
IF t0 = 0 AND n0 = 3
THEN RAISE INFO 'PASSED - Stop at the beginning of the trajectory';
ELSE RAISE INFO 'FAILED - Stop at the beginning of the trajectory';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.remove_pts_from_stop_beginning() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
-- while the distance between (0 0 0) and (0 1 1) would qualify as a stop, it doesn't last long enough
-- therefore (0 0 0) has to be removed in order to detect the stop from (0 1 1) to (0 1.2 3)
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 1 1, 0 1.1 2, 0 1.2 3)'),1,2) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;	
IF t0 = 1 AND n0 = 3
THEN RAISE INFO 'PASSED - Remove point from beginning of stop';
ELSE RAISE INFO 'FAILED - Remove point from beginning of stop';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.no_stops() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 1 1 1, 2 2 2, 3 3 3)'),1,1) stop )
SELECT Count(stop) FROM temp INTO n0;	
IF n0 = 0
THEN RAISE INFO 'PASSED - No stops';
ELSE RAISE INFO 'FAILED - No stops';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.move_stop_start() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
-- while the distance between (0 0 0) and (0 1 1) would qualify as a stop, it doesn't last long enough
-- therefore (0 0 0) has to be removed in order to detect the stop from (0 1 1) to (0 1.2 3)
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 1 1, 0 1.1 2, 0 1.2 3)'),1,2) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;	
IF t0 = 1 AND n0 = 3
THEN RAISE INFO 'PASSED - Move start of stop';
ELSE RAISE INFO 'FAILED - Move start of stop';
END IF;
END; 
$BODY$;


CREATE OR REPLACE FUNCTION test.move_stop_beginning() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
-- while the distance between (0 0 0) and (0 1 1) would qualify as a stop, it doesn't last long enough
-- therefore (0 0 0) has to be removed in order to detect the stop from (0 1 1) to (0 1.2 3)
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 1 1, 0 1.1 2, 0 1.2 3)'),1,2) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;	
IF t0 = 1 AND n0 = 3
THEN RAISE INFO 'PASSED - Move start of stop';
ELSE RAISE INFO 'FAILED - Move start of stop';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.long_stop_segment() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
DECLARE t0 integer; n0 integer;
BEGIN 
WITH temp AS ( SELECT AG_DetectStops(ST_GeometryFromText('LinestringM(0 0 0, 0 1 1, 0 0 2, 0 1 3, 0 0 4, 5 5 5)'),1,1) stop )
SELECT ST_M(ST_StartPoint((stop).geom)), ST_NPoints((stop).geom) FROM temp INTO t0, n0;		
IF t0 = 0 AND n0 = 5
THEN RAISE INFO 'PASSED - Long distance stop segment';
ELSE RAISE INFO 'FAILED - Long distance stop segment';
END IF;
END; 
$BODY$;

CREATE OR REPLACE FUNCTION test.detectstops() RETURNS void LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
PERFORM test.stop_at_beginning();
PERFORM test.stop_at_end();
PERFORM test.move_stop_beginning();
PERFORM test.two_stops();
PERFORM test.two_stops_with_gap();
PERFORM test.no_stops();
PERFORM test.too_short();
PERFORM test.long_stop_segment();
END; 
$BODY$;

SELECT test.detectstops();