require 'log4r'

require 'fetching'
require 'db'

module Controller
	@@LOG = Log4r::Logger.get('info')
	@@CURRS_OER = ['HRK', 'EUR', 'USD', 'CHF', 'GBP',
		'AUD', 'CAD', 'BRL', 'JPY', 'DKK', 'NOK', 'SEK']

	def self.fetch_rates_zaba(db_conn, start_year, start_num,
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
		prns.each do |prn|
			begin
				@@LOG.debug("Storing rates for #{prn.date}")
				DB.store_rates(db_conn, base, prn.rates, prn.date)
				success_count += 1
			rescue PG::UniqueViolation => e
				@@LOG.info("While persisting rates for #{prn.date}: #{e.message}")
			rescue Exception => e
				@@LOG.error("While persisting rates for #{prn.date}", e)
			end
		end

		@@LOG.info("#{success_count} record(s) stored successfully.")
	end

	def self.period_stats(db_conn, periods_months)
		stats_months = {}
		periods_months.each do |months|
			start_date = Date.today << months
			@@LOG.info("Fetching stats since #{start_date}.")
			stats_months[months] = DB.get_stats(db_conn, start_date)
		end

		return stats_months
	end

	def self.fetch_rates_oer(app_id, db_conn, date)
		res = Fetching.fetch_historical(app_id, date)
		base = res['base']
		# Extract only the currencies found in @@CURRS_OER.
		selected = res['rates'].select do |code, rate|
			@@CURRS_OER.include? code
		end

		DB.store_means(db_conn, base, selected, date)
	end

	def self.fetch_currencies_oer(db_conn)
		currs = Fetching.fetch_currencies
		DB.update_currencies(db_conn, currs)
	end
end