

--All Users = 3731 
--SELECT * FROM ##T 

--Inavild Users = 807
--SELECT * FROM ##T
--WHERE user_Key = ''




;WITH CTE_Invalid_userkey AS
(
	SELECT * FROM
		(
		SELECT 
			user_key, 
			STRING_AGG(event_name,',') AS Summery 
		FROM
			(
				SELECT * FROM ##T 
				WHERE USER_KEY <> ''
			)TBL
		GROUP BY user_key
		)TBL
	WHERE Summery like '%Sign Up Finished%' AND Summery not like '%Sign Up Started%'
	
	UNION
	
	SELECT * FROM
		(
		SELECT 
			user_key, 
			STRING_AGG(event_name,',') AS Summery 
		FROM
			(
				SELECT * FROM ##T 
				WHERE USER_KEY <> ''
			)TBL
		GROUP BY user_key
		)TBL
	WHERE Summery like '%Email verified%' AND (Summery not like '%Sign Up Finished%' OR Summery not like '%Sign Up Started%')
	
	UNION 
	
	SELECT * FROM
		(
		SELECT 
			user_key, 
			STRING_AGG(event_name,',') AS Summery 
		FROM
			(
				SELECT * FROM ##T 
				WHERE USER_KEY <> ''
			)TBL
		GROUP BY user_key
		)TBL
	WHERE Summery like '%IDNow Finished%' AND 
	(Summery not like '%Email verified%' OR Summery not like '%Sign Up Finished%' OR Summery not like '%Sign Up Started%')
)


SELECT * FROM 
         (
			SELECT * FROM ##T 
			WHERE USER_KEY <> ''
		)TBL
WHERE user_key  in (SELECT  user_key FROM CTE_Invalid_userkey)

















return









SELECT user_key, COUNT(*) AS CNT FROM 
         (
			SELECT * FROM ##T 
			WHERE USER_KEY <> ''
		)TBL
GROUP BY user_key,event_name 
HAVING count(*)>1





SELECT * FROM ##T WHERE user_key = '1ebf06bdd3e957407a8df06024207feb'