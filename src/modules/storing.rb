require 'pg'
require 'date'	# required by upsert (lame)
require 'upsert'

module Storing
	STORE_MEANS =
		"INSERT INTO rates (rat_mean, rat_base_cur_id, rat_target_cur_id, rat_date) " +
			"SELECT $1, bases.cur_id, targets.cur_id, $2 " +
			"FROM currencies AS bases " +
			"JOIN currencies AS targets ON 1=1 " +
			"WHERE bases.cur_code = $3 " +
			"AND targets.cur_code = $4"

	# Returns a connection object to the Postgres database hosted
	# at Heroku.
	# Make sure to close the returned connection when done
	# communicating with the DB
	def self.connect(password)
		conn = PGconn.connect(
			:host => 'ec2-54-228-233-186.eu-west-1.compute.amazonaws.com',
			:port => 5432,
			:dbname => 'd8odrvi88ngso9',
			:user => 'omujuxwxphgjhk',
			:password => password)
		return conn
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
			conn.exec_params(STORE_MEANS, [rate, date, base, target])
		end
	end
end