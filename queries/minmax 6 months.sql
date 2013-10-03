select cur_code, min(rat_buy) as min_buy, min(rat_sell) as min_sell,
	max(rat_buy) as max_buy, max(rat_sell) as max_sell
	from rates join currencies on rat_target_cur_id = cur_id
	where rat_date >= now()::date - interval '6 months'
	group by cur_code
	order by cur_code