require 'logger'
require 'date'

module Parsing
	CODE_IDX = 1
	QUOT_IDX = 2
	BUY_IDX = 4
	MEAN_IDX = 5
	SELL_IDX = -2

	DATE_IDX = -1
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

	def self.parse_prn(text)
		date = nil
		rates = {}
		text.lines.each do |line|
			tokens = line.split

			length = tokens.length
			if length == 7 || length == 8
				code = tokens[CODE_IDX]
				quotient = BigDecimal(tokens[QUOT_IDX])
				buy = BigDecimal(tokens[BUY_IDX]) / quotient
				sell = BigDecimal(tokens[SELL_IDX]) / quotient

				if length == 7
					# No mean rate
					mean = nil
				else
					mean = BigDecimal(tokens[MEAN_IDX]) / quotient
				end

				rates[code] = Rate.new(buy, mean, sell)
			elsif length > 8
				LOG.debug(tokens[DATE_IDX])
				date = Date.strptime(tokens[DATE_IDX], DATE_FORMAT)
			end
		end

		Prn.new(date, rates)
	end
end