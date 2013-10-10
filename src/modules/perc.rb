# Contains statistics in percentages for a single record
class Perc
	attr_reader :latest
	attr_reader :worst
	attr_reader :avg
	attr_reader :best

	def initialize(latest, worst, avg, best)
		@latest = latest
		@worst = worst
		@avg = avg
		@best = best
	end
end