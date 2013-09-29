load 'modules/fetching.rb'
load 'modules/storing.rb'
require 'io/console'

puts 'Postgres DB password:'
pass = STDIN.noecho(&:gets).chomp

currs = Fetching.fetch_currencies
conn = Storing.create_conn(pass)
Storing.update_currencies(conn, currs)
conn.close