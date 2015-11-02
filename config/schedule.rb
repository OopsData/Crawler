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
    # ==================================================
    every 1.day, :at => '03:00 am' do
      runner "TiebaPost.crawl_yesterday_data('我们15个')"
    end
    every 1.day, :at => '03:15 am' do
      runner "TiebaPost.crawl_yesterday_data('完美假期')"
    end
    every 1.day, :at => '03:30 am' do
      runner "TiebaPost.crawl_yesterday_data('最强小孩')"
    end
    every 1.day, :at => '03:45 am' do
      runner "TiebaPost.crawl_yesterday_data('变形记')"
    end    
    every 1.day, :at => '04:00 am' do
      runner "TiebaPost.crawl_yesterday_data('中国好声音')"
    end
    every 1.day, :at => '04:15 am' do
      runner "TiebaPost.crawl_yesterday_data('爸爸回来了')"
    end
    every 1.day, :at => '04:30 am' do
      runner "TiebaPost.crawl_yesterday_data('挑战者联盟')"
    end
    every 1.day, :at => '04:45 am' do
      runner "TiebaPost.crawl_yesterday_data('为她而战')"
    end    
end










