require 'controller'
require 'db'

module UI
	@@LOG = Log4r::Logger.get('info')

	@@STATS = "1"
	@@FETCH_RATES = "2"
	@@FETCH_HIST_RATES = "3"
	@@QUIT = "0"

	@@PERIODS_MONTHS = [24, 12, 6, 1]

	def self.start_app(app_id, db_pass)
		DB.connect(db_pass) do |db_conn|
			begin
				puts
				puts "Choose an action:"
				puts "#{@@STATS}: Show statistics"
				puts "#{@@FETCH_RATES}: Fetch latest rates"
				puts "#{@@FETCH_HIST_RATES}: Fetch historical rates"
				puts "#{@@QUIT}: Quit"
				action = gets.chomp
				act(db_conn, action)
			end until action == @@QUIT
		end
	end

	private

	def self.act(db_conn, action)
		case action
		when @@QUIT
			puts "Exiting."
		when @@STATS
			stats(db_conn)
		when @@FETCH_RATES
			fetch_rates(db_conn, false)
		when @@FETCH_HIST_RATES
			fetch_rates(db_conn, true)
		else
			puts "Command not recognized."
		end

	end

	def self.stats(db_conn)
		period_stats = Controller.period_stats(db_conn, @@PERIODS_MONTHS)
		period_percs = Controller.to_percs_months(period_stats)
		period_stats.each do |months, stats|
			print_stats(stats, months)
			prompt_continue

			percs = period_percs[months]
			print_percs(percs, months)
			prompt_continue
		end
	end

	def self.print_stats(stats, months)
		puts
		puts "Rates for the past #{months} month(s):"
		puts "-" * 82
		print "Currency | Latest sell | Min sell | "
		print "Avg sell | "
		print "Avg buy".ljust(8) + " | "
		print "Max buy".ljust(8) + " | "
		puts "Latest buy |"
		puts "=" * 82

		stats.each do |cur, stat|
			print "#{cur}".ljust(8) + " | "
			print "#{stat.latest_sell.round(6)}".ljust(11) + " | "
			print "#{stat.min_sell.round(6)}".ljust(8) + " | "
			print "#{stat.avg_sell.round(6)}".ljust(8) + " | "
			print "#{stat.avg_buy.round(6)}".ljust(8) + " | "
			print "#{stat.max_buy.round(6)}".ljust(8) + " | "
			puts "#{stat.latest_buy.round(6)}".ljust(10) + " |"
		end
	end

	def self.print_percs(percs, months)
		puts "Selling stats for the past #{months} month(s)"
		puts "-" * 68
		print "Currency | Latest sell | "
		print "Worst buy".ljust(11) + " | "
		print "Avg buy".ljust(11) + " | "
		puts "Best buy ".ljust(11) + " |"
		puts "=" * 68
		percs.each do |cur, perc|
			print "#{cur}".ljust(8) + " | "
			print "#{perc[:sell].latest.round(6)}".ljust(11) + " | "
			print "#{perc[:sell].worst.round(6)}".ljust(11) + " | "
			print "#{perc[:sell].avg.round(6)}".ljust(11) + " | "
			puts "#{perc[:sell].best.round(6)}".ljust(11) + " |"
		end
	end

	def self.fetch_rates(db_conn, hist)
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
			db_conn, start_year, start_num, end_year, end_num)
	end

	def self.prompt_continue
		puts
		puts "Press RETURN to continue or q to exit..."
		resp = gets.chomp
		if resp == 'q'
			return
		end
	end

end