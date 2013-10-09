require 'pg'
require 'date'	# required by upsert (lame)
require 'upsert'
require 'stat'

module DB
	@@LOG = Log4r::Logger.get('info')

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

	@@GET_RATES =
		"SELECT cur_code, rat_sell, rat_buy
			FROM rates JOIN currencies ON rat_target_cur_id = cur_id
			ORDER BY rat_date, cur_code
			LIMIT "

	@@GET_STATS =
		"WITH latest AS (
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
			WHERE rat_date >= $1
			GROUP BY cur_code, latest_sell, latest_buy
			ORDER BY cur_code"


	# Returns a connection object to the Postgres database hosted
	# at Heroku.
	# Make sure to close the returned connection when done
	# communicating with the DB
	def self.connect(password)
		@@LOG.info("Connecting to database...")
		PGconn.connect(
			:host => 'ec2-54-228-233-186.eu-west-1.compute.amazonaws.com',
			:port => 5432,
			:dbname => 'd8odrvi88ngso9',
			:user => 'omujuxwxphgjhk',
			:password => password) do |conn|
			@@LOG.info("Connected.")
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

	def self.get_stats(conn, start_date)
		param = start_date.to_s
		results = conn.exec_params(@@GET_STATS, [param])
		stats = {}
		results.each do |result|
			@@LOG.debug("Result: #{result}")
			stats[result['cur_code']] = Stat.new(
				result['latest_sell'].to_f,
				result['min_sell'].to_f,
				result['avg_sell'].to_f,
				result['avg_buy'].to_f,
				result['max_buy'].to_f,
				result['latest_buy'].to_f
			)
		end
		@@LOG.debug("Stats: #{stats}")

		return stats
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