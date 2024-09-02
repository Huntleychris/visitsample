WITH DischargeTimes AS (
  SELECT 
    DATEDIFF(MINUTE, o.starttime, v.dischargetime) AS discharge,
    DATEPART(HOUR, o.starttime) AS hour_of_day
  FROM visitinfo v
  INNER JOIN orders o ON o.personid = v.personid
  WHERE o.ordertype = 'discharge'
)

SELECT 
  hour_of_day,
  AVG(discharge) AS average_discharge_time
FROM DischargeTimes
GROUP BY hour_of_day
ORDER BY hour_of_day;