
SELECT A.marketing_channel,A.CNT,B.CNT, (B.CNT*1.0/A.CNT)*100 FROM 
(
SELECT marketing_channel, COUNT(*) AS CNT FROM ##T1 
where event_name = 'Sign Up Started'
GROUP BY marketing_channel 
) A
INNER JOIN 
(
SELECT marketing_channel, COUNT(*) AS CNT FROM ##T1 
where event_name = 'Sign Up Finished'
GROUP BY marketing_channel) B
ON A.marketing_channel = B.marketing_channel


SELECT distinct user_key  FROM ##T1
where event_name = 'Sign Up Finished'


SELECT distinct event_name   FROM ##T1