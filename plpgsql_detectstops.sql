CREATE OR REPLACE FUNCTION public.AG_Duration(traj geometry) RETURNS numeric LANGUAGE 'plpgsql' 
AS $BODY$
BEGIN
RETURN ST_M(ST_EndPoint(traj))-ST_M(ST_StartPoint(traj));
END; 
$BODY$;

CREATE OR REPLACE FUNCTION AG_DetectStops(traj geometry, max_size numeric, min_duration numeric)
    RETURNS TABLE(sequence integer, geom geometry) LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
    pt geometry;
    segment geometry;
    is_stop boolean;
    previously_stopped boolean;
    stop_sequence integer;
    p1 geometry;
BEGIN
segment := NULL;
sequence := 0;
is_stop := false;
previously_stopped := false;
p1 := NULL;
FOR pt IN SELECT (ST_DumpPoints(traj)).geom 
LOOP
   IF segment IS NULL AND p1 IS NULL THEN 
      p1 := pt; 
   ELSIF segment IS NULL THEN 
      segment := ST_MakeLine(p1,pt); 
      p1 := NULL;
      --RAISE NOTICE '%', st_astext(segment);
      --RAISE NOTICE 'Length: %', ST_Length((segment));
      IF ST_Length((segment)) <= max_size THEN is_stop := true; END IF;
   ELSE 
      segment := ST_AddPoint(segment,pt); 
      -- if we're in a stop, we want to grow the segment, otherwise we remove points to the specified min_duration
      IF NOT is_stop THEN
         WHILE ST_NPoints(segment) > 2 AND AG_Duration(ST_RemovePoint(segment,0)) >= min_duration LOOP
            segment := ST_RemovePoint(segment,0); 
         END LOOP;
      END IF;
      -- a stop is identified if the segment stays within a circle of diameter = max_size
      --RAISE NOTICE '%', st_astext(segment);
      --RAISE NOTICE 'Length: %', ST_Length((segment));
      IF ST_Length((segment)) <= max_size THEN is_stop := true;  -- not necessary but faster
      ELSIF ST_Distance((ST_StartPoint(segment)),(pt)) > max_size THEN is_stop := false;
      ELSIF ST_MaxDistance(segment,pt) <= max_size THEN is_stop := true;											
      ELSE is_stop := false; 
      END IF;
      -- if we found the end of a stop, we need to check if it lasted long enough
      IF NOT is_stop AND previously_stopped THEN 
         IF ST_M(ST_PointN(segment,ST_NPoints(segment)-1))-ST_M(ST_StartPoint(segment)) >= min_duration THEN
            geom := ST_RemovePoint(segment,ST_NPoints(segment)-1); 
            RETURN NEXT;
            sequence := sequence + 1;
            segment := NULL;
            p1 := pt;
	     END IF;
      END IF;
   END IF;
   previously_stopped := is_stop;
END LOOP;
IF previously_stopped AND AG_Duration(segment) >= min_duration THEN 
   geom := segment; 
   RETURN NEXT; 
END IF;
END; 

$BODY$;													  

WITH temp AS (																			  
SELECT AG_DetectStops(
	ST_GeometryFromText('LinestringM(1 0 0, 
						1 1 1, 
						1 2 2, 1 2 3, 1 2 4, 
						1 3 5, 1 3 6, 
						1 4 7,
					    1 5 8, 1 5 9, 1 5 10, 1 5 11)')
	,0.5 -- max stop diameter
	,2 -- min stop duration
) stop )
SELECT (stop).sequence,
	ST_AsText((stop).geom )
FROM temp;											  