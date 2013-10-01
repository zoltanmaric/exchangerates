require 'modules/fetching.rb'
require 'modules/storing.rb'
require 'io/console'

puts 'Postgres DB password:'
pass = STDIN.noecho(&:gets).chomp

currs = Fetching.fetch_currencies
conn = Storing.connect(pass)
Storing.update_currencies(conn, currs)
conn.close