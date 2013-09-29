require 'pg'
require 'date'	# required by upsert (lame)
require 'upsert'

module Storing
	# Returns a connection object to the Postgres database hosted
	# at Heroku.
	# Make sure to close the returned connection when done
	# communicating with the DB
	def self.create_conn(password)
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
end