load 'modules/fetching.rb'
load 'modules/storing.rb'
require 'io/console'
require 'date'

currs = ['HRK', 'EUR', 'USD', 'CHF', 'GBP', 'AUD', 'CAD', 'BRL']

puts 'Open Exchange Rates App ID: '
app_id = STDIN.noecho(&:gets).chomp
puts 'Postgres DB password: '
pass = STDIN.noecho(&:gets).chomp

date = '2013-09-28'
res = Fetching.fetch_historical(app_id, date)
base = res['base']
# Extract only the currencies found in currs.
selected = res['rates'].select { |code, rate| currs.include? code }
conn = Storing.connect(pass)
Storing.store_means(conn, base, selected, date)

conn.close

puts res