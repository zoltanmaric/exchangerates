require 'logger'
require 'date'

module Parsing
	CODE_IDX = 1
	COEF_IDX = 2
	BUY_IDX = 4
	MEAN_IDX = 5
	SELL_IDX = 6
	# The index of the sell rate when the mean rate is not specified.
	SELL_IDX_NO_MEAN = 5

	DATE_IDX = 9
	DATE_FORMAT = '%d.%m.%Y.'.freeze

	LOG = Logger.new(STDOUT)
	LOG.level = Logger::DEBUG

	class Rate
		attr_reader :buy
		attr_reader :sell
		attr_reader :mean

		def initialize(buy, mean, sell)
			@buy = buy
			@mean = mean
			@sell = sell
		end
	end

	# Contains parsed data from a single .prn file.
	class Prn
		# The date of the rates parsed in the file.
		attr_reader :date
		# A hash of the rates parsed in the given file
		# Key: currency code; value: Rate
		attr_reader :rates

		def initialize(date, rates)
			@date = date
			@rates = rates.clone
		end
	end

	def self.parse_prn(path)
		date = nil
		rates = {}
		File.foreach(path) do |line|
			tokens = line.split

			length = tokens.length
			if length == 7 || length == 8
				code = tokens[CODE_IDX]
				buy = tokens[BUY_IDX]

				if length == 7
					# No mean rate
					mean = nil
					sell = tokens[SELL_IDX_NO_MEAN]
				else
					mean = tokens[MEAN_IDX]
					sell = tokens[SELL_IDX]
				end

				rates[code] = Rate.new(buy, mean, sell)
			elsif length == 10
				LOG.debug(tokens[DATE_IDX])
				date = Date.strptime(tokens[DATE_IDX], DATE_FORMAT)
			end
		end

		Prn.new(date, rates)
	end
end