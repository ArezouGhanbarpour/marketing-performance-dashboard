

;WITH CTE_A AS 
(
	SELECT *, DATEDIFF(MINUTE,lag_date,DATE_) as diff  fROM 
	(
		SELECT *, LEAD(DATE_)OVER(Partition BY user_key order BY event_name ) as lag_date from
		(
			SELECT 
				user_key,
				cast(LEFT(timestamp,19) as datetime) AS Date_,
				event_name,
				marketing_channel 
			FROM ##T
			WHERE user_key <> ''
				AND event_name IN ('Sign Up Started','Sign Up Finished')
		)TBL 
	)TBL1 
	WHERE lag_date IS NOT NULL
--ORDER BY marketing_channel, user_key, Date_
)


SELECT marketing_channel, AVG(DIFF) AVE_Time,MIN(DIFF) as Min_Time,MAX(DIFF) AS Max_Time, COUNT(*) AS CNT  FROM CTE_A
GROUP BY marketing_channel





