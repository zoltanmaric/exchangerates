# Contains statistics of a single currency
class Stat
	attr_reader :latest_sell
	attr_reader :min_sell
	attr_reader :avg_sell
	attr_reader :avg_buy
	attr_reader :max_buy
	attr_reader :latest_buy

	def initialize(latest_sell, min_sell, avg_sell,
			avg_buy, max_buy, latest_buy)
		@latest_sell = latest_sell
		@min_sell = min_sell
		@avg_sell = avg_sell
		@avg_buy = avg_buy
		@max_buy = max_buy
		@latest_buy = latest_buy
	end
end