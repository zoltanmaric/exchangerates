require 'net/http'
require 'json'

# Handles web service communication
module Fetching
	BASE_URL = 'http://openexchangerates.org/api/'
	CURRENCIES = 'currencies.json'
	LATEST = 'latest.json'
	HIST_PATH = 'historical/'
	JSON_EXT = '.json'

	# Fetches the currencies and returns them as a hash.
	# See https://openexchangerates.org/documentation for details
	# on the layout of the hash.
	def self.fetch_currencies
		return fetch_json(BASE_URL + CURRENCIES)
	end

	# Fetch the latest exchange rates as a hash.
	# See https://openexchangerates.org/documentation for details
	# on the layout of the hash.
	def self.fetch_latest
		return fetch_json(BASE_URL + LATEST)
	end

	# Fetches historical exchange rates based on the given date
	# The parameter can be either a Ruby Date object, or a
	# string of the format 'yyyy-mm-dd'.
	def self.fetch_historical(date)
		if date.is_a? Date
			date_string = date.to_s
		else
			date_string = date
		end

		url_string = BASE_URL + HIST_PATH +
			date_string + JSON_EXT
		return fetch_json(url_string)
	end

	# Fetches JSON from the provided URL, parses it,
	# and returns it as a hash.
	def self.fetch_json(url_string)
		url = URI.parse(url_string)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}

		return JSON.parse(res.body)
	end
end


