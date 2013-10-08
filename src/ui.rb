require 'controller'

module UI
	@@LOG = Log4r::Logger.get('info')

	@@STATS = "1"
	@@FETCH_RATES = "2"
	@@FETCH_HIST_RATES = "3"
	@@QUIT = "0"

	@@PERIODS_MONTHS = [1, 6, 12, 24]

	def self.start_app(app_id, db_pass)
		begin
			puts
			puts "Choose an action:"
			puts "#{@@STATS}: Show statistics"
			puts "#{@@FETCH_RATES}: Fetch latest rates"
			puts "#{@@FETCH_HIST_RATES}: Fetch historical rates"
			puts "#{@@QUIT}: Quit"
			action = gets.chomp
			act(db_pass, action)
		end until action == @@QUIT
	end

	private

	def self.act(db_pass, action)
		case action
		when @@QUIT
			puts "Exiting."
		when @@STATS
			stats(db_pass)
		when @@FETCH_RATES
			fetch_rates(db_pass, false)
		when @@FETCH_HIST_RATES
			fetch_rates(db_pass, true)
		else
			puts "Command not recognized."
		end

	end

	def self.stats(db_pass)
		period_stats = Controller.period_stats(db_pass, @@PERIODS_MONTHS)
		period_stats.each do |months, stats|
			puts
			puts "Stats for #{months} month(s):"
			puts "-" * 74
			print "Currency | Min sell | "
			print "Max buy".ljust(8) + " | "
			print "Avg sell | "
			print "Avg buy".ljust(8) + " | "
			print "Max sell | "
			puts "Min buy".ljust(8)
			puts "=" * 74

			stats.each do |cur, stat|
				print "#{cur}".ljust(8) + " | "
				print "#{stat.min_sell.round(6)}".ljust(8) + " | "
				print "#{stat.max_buy.round(6)}".ljust(8) + " | "
				print "#{stat.avg_sell.round(6)}".ljust(8) + " | "
				print "#{stat.avg_buy.round(6)}".ljust(8) + " | "
				print "#{stat.max_sell.round(6)}".ljust(8) + " | "
				puts stat.min_buy.round(6)
			end
			puts
			puts "Press RETURN to continue..."
			gets
		end
	end

	def self.fetch_rates(db_pass, hist)
		print "Enter start year: "
		start_year = gets.chomp.strip.to_i
		print "Enter start number: "
		start_num = gets.chomp.strip.to_i

		end_year = nil
		end_num = nil
		if hist
			print "Enter end year: "
			end_year = gets.chomp.strip.to_i
			print "Enter end number: "
			end_num = gets.chomp.strip.to_i
		end

		Controller.fetch_rates_zaba(
			db_pass, start_year, start_num, end_year, end_num)
	end
end