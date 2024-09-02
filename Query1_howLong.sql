WITH DischargeTimes AS (
  SELECT 
    DATEDIFF(MINUTE, o.starttime, v.dischargetime) AS discharge
  FROM visitinfo v
  INNER JOIN orders o ON o.personid = v.personid
  WHERE o.ordertype = 'discharge'
)

SELECT 
  AVG(discharge) AS average_discharge_time
FROM DischargeTimes;
