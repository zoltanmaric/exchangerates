#
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