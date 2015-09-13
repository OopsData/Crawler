set :output, {
    :error    => "#{path}/log/error.log",
    :standard => "#{path}/log/cron.log"
}

case @environment
when 'production'
    every 1.day, :at => '00:10 am' do
      runner "TiebaTheme.crawl_yesterday_data('我们15个')"
    end
    every 1.day, :at => '00:30 am' do
      runner "TiebaTheme.crawl_yesterday_data('真正男子汉')"
    end
    every 1.day, :at => '00:50 am' do
      runner "TiebaTheme.crawl_yesterday_data('奇葩说')"
    end
    every 1.day, :at => '01:10 am' do
      runner "TiebaTheme.crawl_yesterday_data('爸爸去哪2')"
    end
    every 1.day, :at => '01:30 am' do
      runner "TiebaTheme.crawl_yesterday_data('你正常吗')"
    end
    every 1.day, :at => '01:50 am' do
      runner "TiebaTheme.crawl_yesterday_data('百万粉丝')"
    end
    every 1.day, :at => '02:10 am' do
      runner "TiebaTheme.crawl_yesterday_data('完美假期')"
    end                        
    every 1.day, :at => '00:05 am' do
      runner "Fantuan.crawl_yesterday_data(399)"
    end
end










