require 'logger'
require 'net/http'
require 'json'
require 'log4r'

require 'parsing'

# Handles web service communication
module Fetching
	@@BASE_URL = 'http://openexchangerates.org/api/'
	@@CURRENCIES = 'currencies.json'
	@@LATEST = 'latest.json'
	@@HIST_PATH = 'historical/'
	@@JSON_EXT = '.json'
	@@APP_ID_Q = '?app_id='

	@@ZABA_URL = 'http://www.zaba.hr/home/wps/PA_ZabaPublicSite/UtilServlet'

	@@LOG = Log4r::Logger.get('info')

	def self.prns(start_year, start_num, end_year=nil, end_num=nil)
		unless end_year
			end_year = Time.new.year
		end

		prns = []

		uri = URI(@@ZABA_URL)
		req = Net::HTTP::Post.new(@@ZABA_URL)
		Net::HTTP.start(uri.host, uri.port) do |http|
			num = start_num
			(start_year..end_year).each do |year|
				until end_year == year && end_num == num - 1
					req.set_form_data(
						:broj => num,
						:godina => year,
						:isPdf => false)
					res = http.request(req)

					# Check for response code. Throws exception if not 2xx.
					res.value

					@@LOG.debug("Received #{res.body}")

					# If no exchange rates table was found for the given
					# num, an empty response is returned.
					# It is assumed that this implies that no more
					# exchange rates are available for the given year.
					break if res.body.empty?

					prns << Parsing.parse_prn(res.body)

					num += 1
				end
				num = 1 # restart num for the subsequent year
			end
		end

		return prns
	end

	# Fetches the currencies and returns them as a hash.
	# See https://openexchangerates.org/documentation for details
	# on the layout of the hash.
	def self.fetch_currencies
		return fetch_json(@@BASE_URL + @@CURRENCIES)
	end

	# Fetch the latest exchange rates as a hash.
	# See https://openexchangerates.org/documentation for details
	# on the layout of the hash.
	def self.fetch_latest(app_id)
		url_string = @@BASE_URL + @@LATEST + @@APP_ID_Q + app_id
		return fetch_json(url_string)
	end

	# Fetches historical exchange rates based on the given date
	# The parameter can be either a Ruby Date object, or a
	# string of the format 'yyyy-mm-dd'.
	def self.fetch_historical(app_id, date)
		if date.is_a? Date
			date_string = date.to_s
		else
			date_string = date
		end

		url_string = @@BASE_URL + @@HIST_PATH +
			date_string + @@JSON_EXT + @@APP_ID_Q + app_id
		return fetch_json(url_string)
	end

	# Fetches JSON from the provided URL, parses it,
	# and returns it as a hash.
	def self.fetch_json(url_string)
		@@LOG.info("Fetching #{url_string}")
		url = URI.parse(url_string)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}

		res.value

		@@LOG.debug("Received #{res.body}")

		return JSON.parse(res.body)
	end
end
