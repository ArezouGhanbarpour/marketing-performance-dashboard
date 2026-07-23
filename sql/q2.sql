


/*

-- Überblick über die Struktur der Tabelle, um die verfügbaren Spalten und Daten zu verstehen


SELECT TOP 100 * FROM ##T
/* user_key
   timestamp
   event_name
   marketing_channel
*/

-- Analyse der vorhandenen Event-Typen, um die Schritte im Signup-Funnel zu verstehen

SELECT DISTINCT event_name FROM ##T
/* Email verified
   Sign Up Finished
   Sign Up Started
   IDNow Finished
*/


-- Überprüfung möglicher Duplikate: Analyse der Anzahl von Events pro user_key,
-- da pro user_key maximal vier unterschiedliche Events erwartet werden.

SELECT user_key, COUNT(*) AS CNT FROM ##T
GROUP BY user_key
HAVING COUNT(*) > 4


-- Untersuchung eines user-key mit mehr als vier Events, um mögliche doppelte Events zu identifizieren
-- (z. B. doppelte Email-Verifizierung)

SELECT * FROM ##T
WHERE user_key = '1ebf06bdd3e957407a8df06024207feb'



-- Vergleich der Gesamtzahl der Nutzer mit "signup_started" mit der Anzahl der "signup_started"-Events ohne user_key,
-- um fehlende user-keys im Tracking zu identifizieren.

SELECT 'All_Users' AS Sign_Up_started, COUNT(*) AS CNT_started FROM ##T
WHERE event_name = 'Sign Up Started'

UNION

SELECT 'Users without User_key' AS Sign_Up_started, COUNT(*) AS CNT_started FROM ##T
WHERE event_name = 'Sign Up Started' AND user_key = ''



-- Vergleich der Gesamtzahl der Nutzer mit "signup_finished" mit der Anzahl der "signup_finished"-Events ohne user_key,
-- um fehlende user-keys im Tracking zu identifizieren.

SELECT 'All_Users' AS Sign_Up_finished, COUNT(*) AS CNT_finished FROM ##T
WHERE event_name = 'Sign Up Finished'

UNION

SELECT 'Users without User_key' AS Sign_Up_finished, COUNT(*) AS CNT_finished FROM ##T
WHERE event_name = 'Sign Up Finished' AND user_key = ''


-- Überprüfung des Datumsbereichs mit MIN und MAX, um sicherzustellen,
-- dass alle Events im erwarteten Zeitraum (Oktobers 2021) liegen.

SELECT MIN(timestamp) AS MIN , MAX(timestamp) AS MAX FROM ##T 

*/











/*

;WITH CTE_A AS (
	SELECT
	*, 
	CASE
		WHEN CAST(LEFT(timestamp,10) AS DATE) <= '2021-10-14' THEN 1
		WHEN CAST(LEFT(timestamp,10) AS DATE) > '2021-10-14' THEN 2
		ELSE 'N/A'
	END AS month_part
		FROM ##T WHERE user_key <> ''
)
, CTE_B AS (
	SELECT 
	marketing_channel,
	month_part,
	COUNT (*) AS user_numbers 
	FROM CTE_A
	WHERE event_name = 'Sign Up Finished' 
	GROUP BY marketing_channel, month_part
)
, CTE_C AS (
	SELECT
	*,
	SUM(user_numbers) OVER (PARTITION BY month_part ORDER BY (SELECT 1)) AS total_user_numbers
	FROM CTE_B
)
, CTE_D AS (
	SELECT
	*,
	CAST((user_numbers*1.0/total_user_numbers)*100 AS DECIMAL(4,2)) AS [user_numbers%_per_channel]
	FROM CTE_C
)
, CTE_E AS (
	SELECT
	*
	FROM
	(
		VALUES
		(1,'Instagram Installs',1500),
		(1,'Google Ads Web Search',10000),
		(1,'TikTok',2500),
		(1,'Facebook Installs',2500),
		(2,'Instagram Installs',1000),
		(2,'Google Ads Web Search',8000),
		(2,'TikTok',2000),
		(2,'Facebook Installs',2000)
	)TBL(month_part,marketing_channel,budget)
)
,CTE_F AS
(
	SELECT
	*,
	CAST((budget*1.0/SUM(budget) OVER (PARTITION BY month_part ORDER BY (SELECT 1)))*100 AS DECIMAL(4,2)) AS [total_budget%_per_channel]
	FROM CTE_E
)	

SELECT 
A.month_part,
A.marketing_channel,
A.[total_budget%_per_channel],
B.[user_numbers%_per_channel],
A.budget,
B.user_numbers,
CAST(A.budget*1.0/ B.user_numbers AS DECIMAL(10,2)) AS CAC
FROM CTE_F A
INNER JOIN CTE_D B
ON A.month_part = B.month_part AND A.marketing_channel = B.marketing_channel
ORDER BY month_part, marketing_channel

*/

--CONVERSION RATE


SELECT 
*, 
CAST(CNT*1.0 / LAG_CNT AS DECIMAL(10,2)) AS CNR 
FROM 
(
	SELECT 
	*,
	LEAD(CNT)OVER(PARTITION BY marketing_channel ORDER BY [User] ) AS LAG_CNT FROM
	(
		SELECT 'Sign Up Started' AS [User],marketing_channel, COUNT(*) AS CNT   FROM ##T
		WHERE user_key <> '' AND event_name = 'Sign Up Started'
		GROUP BY marketing_channel
		
		UNION
		
		SELECT 'Sign Up Finished' AS [User],marketing_channel, COUNT(*) AS CNT   FROM ##T
		WHERE user_key <> '' AND event_name = 'Sign Up Finished'
		GROUP BY marketing_channel
	)TBL1
)TBL2
WHERE LAG_CNT IS NOT NULL 

/* DATA QUALITY

;WITH CTE_A AS 
(
SELECT * FROM ##T
WHERE user_key <> ''  AND marketing_channel = 'Facebook Installs' AND EVENT_name = 'Sign Up Finished'
)
,CTE_B AS 
(
SELECT * FROM ##T
WHERE user_key <> ''  AND marketing_channel = 'Facebook Installs' AND EVENT_name = 'Sign Up Started'
)

SELECT  A.user_key , B.user_key fROM  CTE_A  A
LEFT JOIN CTE_B B ON A.user_key = B.user_key
--WHERE B.user_key IS NULL 


/*
SELECT * FROM CTE_A
WHERe user_key in
(
'5daa160d42eb845295098cdfea32aa36'
,'6fb0c23a066bd6f2557da9fcf1759232'
,'747e8c2a8a62bbf7c68bb1eb4ae592a9'
,'756cfab6731446325c2eb1ca9906c514'
,'774d456e9df778b93452838723c50b94'
,'933ed97463cb41d3b3e6ff972ac46991'
,'f617abcef14ac7af01fb93e8de5079bd'
,'fb053e92acad2739c7ad6851bde9972a'
)
ORDER By user_key, event_name
*/


SELECT * FROM ##T 
GROUP BY 
