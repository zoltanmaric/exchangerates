# Contains exchange rate information for a single currency.
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