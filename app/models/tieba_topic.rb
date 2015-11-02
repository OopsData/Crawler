require 'spreadsheet'
require 'movie_spider'
Spreadsheet.client_encoding = 'UTF-8'
class TiebaTopic

  TIEBA_HASH = {
    "我们15个" => {name:"我们15个",link: "http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8&pn=0",max_pn:41000},
    "完美假期" => {name:"完美假期",link: "http://tieba.baidu.com/f?kw=%E5%AE%8C%E7%BE%8E%E5%81%87%E6%9C%9F&ie=utf-8&pn=0",max_pn:700},
    "最强小孩" => {name: "最强小孩", link: "http://tieba.baidu.com/f?kw=%E6%9C%80%E5%BC%BA%E5%B0%8F%E5%AD%A9&ie=utf-8&pn=0", max_pn:200},
    "变形记" => {name: "变形记", link: "http://tieba.baidu.com/f?kw=%E5%8F%98%E5%BD%A2%E8%AE%B0&ie=utf-8&pn=0", max_pn: 30150},
    "中国好声音" => {name: "中国好声音", link: "http://tieba.baidu.com/f?kw=%E4%B8%AD%E5%9B%BD%E5%A5%BD%E5%A3%B0%E9%9F%B3&ie=utf-8&pn=0", max_pn: 709750},
    "爸爸回来了" => {name: "爸爸回来了", link: "http://tieba.baidu.com/f?kw=%E7%88%B8%E7%88%B8%E5%9B%9E%E6%9D%A5%E4%BA%86&ie=utf-8&pn=0", max_pn: 8500},
    "挑战者联盟" => {name: "挑战者联盟", link: "http://tieba.baidu.com/f?kw=%E6%8C%91%E6%88%98%E8%80%85%E8%81%94%E7%9B%9F&ie=utf-8&pn=0", max_pn: 2500},
    "为她而战" => {name: "为她而战", link: "http://tieba.baidu.com/f?kw=%E4%B8%BA%E5%A5%B9%E8%80%8C%E6%88%98&ie=utf-8&pn=0", max_pn: 2600}
  }

  def self.crawl_yesterday_data(name, max_pn=3000)
    from = to = (Date.today -1.days).strftime('%F')
    runing_history_tasks(0, name, max_pn)
  end

  def self.runing_history_tasks(spn, name,max_pn=nil)
    hash        =  TIEBA_HASH["#{name}"]
    max_pn    ||= hash[:max_pn]
    threads     = []
    (spn...max_pn).each_slice(3000) do |pn_arr|
      threads << Thread.new {
        spn   = pn_arr.first 
        epn   = pn_arr.last 
        link  = hash[:link].gsub(/pn=0/,"pn=#{spn}")
        limit = epn 
        tieba = MovieSpider::Tieba.new(name,link,Rails.root.to_s + '/cookies.txt',limit)
        res   = tieba.start_crawl
        save_history_data(name,res)
      }
    end
    threads.each { |thr| thr.join }
  end

  #保存抓取到的数据
  def self.save_history_data(name,res)
    res.each do |tid,data|
      url = "http://localhost:9200/crawler/tieba/#{tid}"
      data.merge!({name:name,tid:tid})
      begin
        data = JSON.generate(data)
        RestClient.put "#{url}", data, {:content_type => :json}
      rescue
        next
      end  
    end
  end
  
end

