# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, {
    :error    => "#{path}/log/error.log",
    :standard => "#{path}/log/cron.log"
}

case @environment
when 'production'
	# every 1.day, :at => '00:10 am' do
	#   runner "TiebaTheme.crawl_yesterday_data(3000)"
	# end

	# every 1.day, :at => '00:05 am' do
	#   runner "Fantuan.crawl_yesterday_data(399)"
	# end

	# every 1.day, :at => '6:00 pm' do
	#   runner "TiebaTheme.crawl_history_data"
	# end

	# every 1.day, :at => '00:00 am' do
	#   runner "Task.runing_tieba_history_data_tasks"
	# end	


	

	# every 3.days, :at => '17:30 pm' do 
	# 	runner "Task.runing_fifteen_tieba_tasks"
	# end

	# every 3.days, :at => '18:30 pm' do 
	# 	runner "Task.runing_fifteen_fantuan_tasks"
	# end

	# every 2.minutes do 
	# 	runner "Task.runing_fifteen_qqlive_tasks"
	# end

	# every 1.day, :at => '23:50 pm' do
	#   runner "Task.export_qqlive_datas_excel"
	# end
end



