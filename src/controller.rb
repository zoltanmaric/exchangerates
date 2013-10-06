require 'log4r'

require 'fetching'
require 'db'

module Controller
	@@LOG = Log4r::Logger.get('info')
	@@CURRS_OER = ['HRK', 'EUR', 'USD', 'CHF', 'GBP',
		'AUD', 'CAD', 'BRL', 'JPY', 'DKK', 'NOK', 'SEK']

	def self.fetch_rates_zaba(db_pass, start_year, start_num,
			end_year = nil, end_num = nil)
		end_message = end_year ? end_year.to_s : 'today'
		end_message += end_num ? " \##{end_num}" : ''

		@@LOG.info("Fetching exchange rates from #{start_year} " +
			"\##{start_num} until #{end_message}.")
		prns = Fetching.prns(start_year, start_num, end_year, end_num)

		@@LOG.info("Fetched and parsed #{prns.length} PRN files.")


		if @@LOG.debug?
			prns.each do |prn|
				@@LOG.debug(prn.inspect)
			end
		end

		base = 'HRK'
		success_count = 0
		DB.connect(db_pass) do |conn|
			prns.each do |prn|
				begin
					@@LOG.debug("Storing rates for #{prn.date}")
					DB.store_rates(conn, base, prn.rates, prn.date)
					success_count += 1
				rescue PG::UniqueViolation => e
					@@LOG.info("While persisting rates for #{prn.date}: #{e.message}")
				rescue Exception => e
					@@LOG.error("While persisting rates for #{prn.date}", e)
				end
			end
		end

		@@LOG.info("#{success_count} record(s) stored successfully.")
	end

	def self.fetch_rates_oer(app_id, db_pass, date)
		res = Fetching.fetch_historical(app_id, date)
		base = res['base']
		# Extract only the currencies found in @@CURRS_OER.
		selected = res['rates'].select do |code, rate|
			@@CURRS_OER.include? code
		end

		conn = DB.connect(db_pass)
		DB.store_means(conn, base, selected, date)
		conn.close
	end

	def self.fetch_currencies_oer(db_pass)
		currs = Fetching.fetch_currencies
		conn = DB.connect(db_pass)
		DB.update_currencies(conn, currs)
		conn.close
	end
end