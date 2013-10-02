require_relative 'modules/fetching.rb'
require_relative 'modules/storing.rb'
require_relative 'modules/parsing.rb'
require 'yaml'

PROPS = 'keys.yml'

props = YAML.load_file(PROPS)
pass = props['db_pass']

start_year = 2013
start_num = 189

prns = Fetching.prns(start_year, start_num)
puts prns

base = 'HRK'
conn = Storing.connect(pass)
begin
	prns.each do |prn|
		puts prn.rates
		Storing.store_rates(conn, base, prn.rates, prn.date)
	end
ensure
	conn.close
end
