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
	every 1.day, :at => '1:30 am' do
	  runner "Task.runing_movie_tasks"
	end

	every 1.day, :at => '15:00 pm' do 
		runner "Task.runing_tieba_tasks"
	end


	every 5.minutes do 
		runner "Task.runing_qqlive_tasks"
	end

	# every 1.day, :at => '13:00 pm' do
	#   runner "Task.runing_tieba_tasks"
	# end

	# every 1.day, :at => '3:00 am' do
	#   runner "Task.runing_news_tasks"
	# end
when 'development'
	# every 1.day, :at => '14:38 pm' do
	#   runner "Task.runing_movie_tasks"
	# end
	
	# every 1.day, :at => '15:40 pm' do
	#   runner "Task.runing_news_tasks"
	# end
end



