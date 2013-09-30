load 'modules/fetching.rb'
load 'modules/storing.rb'
require 'date'
require 'yaml'

CURRS = ['HRK', 'EUR', 'USD', 'CHF', 'GBP', 'AUD', 'CAD', 'BRL']
PROPS = 'keys.yml'

props = YAML.load_file(PROPS)

app_id = props['app_id']
pass = props['db_pass']

date = '2013-09-28'
res = Fetching.fetch_historical(app_id, date)
base = res['base']
# Extract only the currencies found in CURRS.
selected = res['rates'].select { |code, rate| CURRS.include? code }
conn = Storing.connect(pass)
Storing.store_means(conn, base, selected, date)

conn.close

puts res