set :output, {
    :error    => "#{path}/log/error.log",
    :standard => "#{path}/log/cron.log"
}

case @environment
when 'production'
    every 1.day, :at => '00:10 am' do
      runner "TiebaTheme.crawl_yesterday_data(3000)"
    end

    every 1.day, :at => '00:05 am' do
      runner "Fantuan.crawl_yesterday_data(399)"
    end
end
