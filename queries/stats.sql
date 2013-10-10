WITH latest AS (
	SELECT rat_sell AS latest_sell,
		rat_buy AS latest_buy,
		rat_target_cur_id AS latest_cur_id
		FROM rates
		WHERE rat_date =
		(SELECT rat_date FROM rates
			ORDER BY rat_date DESC LIMIT 1)
)
SELECT cur_code, latest_sell, min(rat_sell) AS min_sell,
	avg(rat_sell) AS avg_sell, avg(rat_buy) AS avg_buy,
	max(rat_buy) AS max_buy, latest_buy
	FROM rates
	JOIN latest ON rat_target_cur_id = latest_cur_id
	JOIN currencies ON rat_target_cur_id = cur_id
	WHERE rat_date >= '2013-04-09'
	GROUP BY cur_code, latest_sell, latest_buy
	ORDER BY cur_code