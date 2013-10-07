require 'pg'
require 'date'	# required by upsert (lame)
require 'upsert'

module DB
	@@STORE_MEANS =
		"INSERT INTO rates (rat_mean, rat_base_cur_id, rat_target_cur_id, rat_date) " +
			"SELECT $1, bases.cur_id, targets.cur_id, $2 " +
			"FROM currencies AS bases " +
			"JOIN currencies AS targets ON 1=1 " +
			"WHERE bases.cur_code = $3 " +
			"AND targets.cur_code = $4"

	@@STORE_RATES =
		"INSERT INTO rates (rat_buy, rat_mean, rat_sell, rat_base_cur_id, rat_target_cur_id, rat_date) " +
			"SELECT $1, $2, $3, bases.cur_id, targets.cur_id, $4 " +
			"FROM currencies AS bases " +
			"JOIN currencies AS targets ON 1=1 " +
			"WHERE bases.cur_code = $5 " +
			"AND targets.cur_code = $6"

	@@GET_STATS =
		"SELECT cur_code, min(rat_sell) AS min_sell, max(rat_buy) AS max_buy,
			avg(rat_sell) AS avg_sell, avg(rat_buy) AS avg_buy,
			max(rat_sell) AS max_sell, min(rat_buy) AS min_buy
			FROM rates JOIN currencies ON rat_target_cur_id = cur_id
			WHERE rat_date >= now()::date - INTERVAL '$1 months'
			GROUP BY cur_code
			ORDER BY cur_code"


	# Returns a connection object to the Postgres database hosted
	# at Heroku.
	# Make sure to close the returned connection when done
	# communicating with the DB
	def self.connect(password)
		PGconn.connect(
			:host => 'ec2-54-228-233-186.eu-west-1.compute.amazonaws.com',
			:port => 5432,
			:dbname => 'd8odrvi88ngso9',
			:user => 'omujuxwxphgjhk',
			:password => password) do |conn|
			yield(conn)
		end
	end

	def self.store_rates(conn, base, rates, date)
		rates.each do |target, rate|
			conn.exec_params(@@STORE_RATES,
				[
					rate.buy,
					rate.mean,
					rate.sell,
					date,
					base,
					target
				])
		end
	end

	def self.get_stats(conn, months)
		results = 
	end

	# Updates or inserts the given currencies in the database
	def self.update_currencies(conn, currs)
		table_name = :currencies
		Upsert.batch(conn, table_name) do |upsert|
			currs.each do |code, desc|
				upsert.row({:cur_code => code}, :cur_desc => desc)
			end
		end
	end

	def self.store_means(conn, base, rates, date)
		rates.each do |target, rate|
			conn.exec_params(@@STORE_MEANS, [rate, date, base, target])
		end
	end
end