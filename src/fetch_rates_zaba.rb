require 'yaml'
require 'log4r'
require 'log4r/yamlconfigurator'

Log4r::YamlConfigurator.load_yaml_file('log4r.yml')

require_relative 'modules/fetching.rb'
require_relative 'modules/storing.rb'
require_relative 'modules/parsing.rb'

LOG = Log4r::Logger.get('info')
PROPS = 'keys.yml'

unless ARGV.length >= 2 || ARGV.length <= 4
	LOG.info("Usage: ruby #{$0} start_year start_num [end_year [end_num]]. " +
		"Exiting.")
	exit!
end

start_year = ARGV[0].to_i
start_num = ARGV[1].to_i
end_year = ARGV[2].to_i
end_num = ARGV[3].to_i

props = YAML.load_file(PROPS)
pass = props['db_pass']

end_message = end_year ? end_year.to_s : 'today'
end_message += end_num ? " \##{end_num}" : ''

LOG.info("Fetching exchange rates from #{start_year} " +
	"\##{start_num} until #{end_message}.")
prns = Fetching.prns(start_year, start_num, end_year, end_num)

LOG.info("Fetched and parsed #{prns.length} files.")


if LOG.debug?
	prns.each do |prn|
		LOG.debug(prn.inspect)
	end
end

base = 'HRK'
Storing.connect(pass) do |conn|
	prns.each do |prn|
		begin
			LOG.debug("Storing rates for #{prn.date}")
			Storing.store_rates(conn, base, prn.rates, prn.date)
		rescue PG::UniqueViolation => e
			LOG.info("While persisting rates for #{prn.date}: #{e.message}")
		rescue Exception => e
			LOG.error("While persisting rates for #{prn.date}", e)
		end
	end
end
