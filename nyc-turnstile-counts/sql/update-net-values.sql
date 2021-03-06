SET work_mem = '256MB';
WITH net_observations AS (
SELECT
   id,
   entries - lag(entries, 1) OVER w AS calculated_net_entries,
   exits - lag(exits, 1) OVER w AS calculated_net_exits
 FROM turnstile_observations
 WINDOW w AS (PARTITION BY unit_id ORDER BY observed_at)
)
UPDATE turnstile_observations
SET
 net_entries = CASE WHEN abs(calculated_net_entries) < 10000 THEN abs(calculated_net_entries) END,
 net_exits = CASE WHEN abs(calculated_net_exits) < 10000 THEN abs(calculated_net_exits) END
FROM net_observations
WHERE turnstile_observations.id = net_observations.id
AND net_entries IS NULL;
