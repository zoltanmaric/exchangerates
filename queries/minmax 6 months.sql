SELECT cur_code, min(rat_sell) AS min_sell, max(rat_buy) AS max_buy,
	avg(rat_sell) AS avg_sell, avg(rat_buy) AS avg_buy,
	max(rat_sell) AS max_sell, min(rat_buy) AS min_buy
	FROM rates JOIN currencies ON rat_target_cur_id = cur_id
	WHERE rat_date >= now()::date - INTERVAL '6 months'
	GROUP BY cur_code
	ORDER BY cur_code