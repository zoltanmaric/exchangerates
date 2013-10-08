# Contains statistics of a single currency
class Stat
	attr_reader :min_sell
	attr_reader :max_buy
	attr_reader :avg_sell
	attr_reader :avg_buy
	attr_reader :max_sell
	attr_reader :min_buy

	def initialize(min_sell, max_buy, avg_sell,
			avg_buy, max_sell, min_buy)
		@min_sell = min_sell
		@max_buy = max_buy
		@avg_sell = avg_sell
		@avg_buy = avg_buy
		@max_sell = max_sell
		@min_buy = min_buy
	end
end