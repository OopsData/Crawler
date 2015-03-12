require 'movie_spider'
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
class Task
  include Mongoid::Document
  include Mongoid::Timestamps



  ENABLE  = 1
  DISABLE = 0
  SITE_ARR = ['tudou','youku','tecent','iqiyi']
  field :title, type: String
  field :url, type: String
  field :site, type: String
  field :keyword,type:String
  field :start_date,type:String
  field :end_date,type:String
  field :type,type:String,default:'video'
  field :status, type: Integer,default:ENABLE

  def show_status
  	return '正常' if status == 1
  	return '终止' if status == 0 
  end

  def self.gs_new(url)
  	url      = url.gsub(/：：/,'::')
  	info_arr = url.split(/::/)
  	title    = info_arr.first
  	url      = info_arr.last
  	site     = guess_site(url)
  	self.create(title:title,url:url,site:site)
  end

  def self.guess_site(url)
  	return '豆瓣' if url.include?('douban')
  	return '优酷' if url.include?('youku')
  	return '土豆' if url.include?('tudou')
  	return '腾讯' if url.include?('qq')
  	return '爱奇艺' if url.include?('iqiyi')
  end

  def self.runing_movie_tasks
    movies = []

    self.where(status:ENABLE,site:'豆瓣').each do |task|
      threads = []
      douban  =  MovieSpider::Douban.new(task.url)
      data    =  douban.get_basic_info
      movie   =  Movie.create(title:task.title,director:data[:director],writer:data[:writer],actor:data[:actor],type:data[:type],area:data[:area],language:data[:language],length:data[:length],descript:data[:desc])
      movies  << movie.id.to_s

      SITE_ARR.each do |site|
        threads << Thread.new{
          movie.send("runing_#{site}_tasks")
        }
      end
      threads.each { |thr| thr.join }
      Rails.logger.info '*************** one movie finished ***************'
      # movie.runing_tudou_tasks
      # movie.runing_youku_tasks
      # movie.runing_tecent_tasks
      # movie.runing_iqiyi_tasks
    end
    generage_movie_excel(movies)
  end

  def self.runing_news_tasks
    news  = []
    tasks =  self.where(status:ENABLE,type:'news')
    tasks.map(&:keyword).each do |kwd|
      tasks.where(keyword:kwd).each do |task|
        #每天后半夜爬取截止到前一天的数据
        baidu  = MovieSpider::Baidu.new(task.keyword,task.start_date,(Date.today - 1.days).strftime('%Y-%-m-%-d'))
        data   = baidu.get_news_list
        data.each do |d|
          param = {keyword:task.keyword,title:d[:title],link:d[:link],time:d[:time],start_date:task.start_date,end_date:task.end_date,num:d[:num],media:d[:media],reps:d[:reps],summary:d[:summary]}
          ad = Administrivium.where(link:d[:link]).first
          if ad.present?
            #第二天抓取的数据如果与第一天抓取的数据连接相同，则认为是同一条数据，那么只更新该数据,这个时候前一天的数据变为今天的数据
            ad.update_attributes(param)
            news << ad.id.to_s
          else
            #第二天抓取的数据的连接如果在第一天抓取的数据不存在，则认为是一条新的数据,插入数据库
            ns = Administrivium.create(param)
            news << ns.id.to_s
          end
        end
      end      
    end
    # 只把今天的数据导出
    generage_news_excel(news)
  end

  def self.runing_stars_tasks
    stars = %w(刘诗诗 刘亦菲 鹿晗 倪妮 欧豪 彭于晏 汤唯 佟丽娅 王宝强 吴亦凡 谢依霖 杨幂 杨洋 杨颖、AngelaBaby 袁泉 赵薇 赵又廷 郑恺 钟汉良 周冬雨 周迅 井柏然 李晨)
    hash = Hash.new()
    stars.each do |s|
      star = MovieSpider::Star.new("#{s}",'2014-4-1','2015-4-1')
      hash["#{s}"] =  star.get_special_site_news_list
    end
    generage_star_excel(hash)
  end

  def self.runing_tieba_tasks
  #TODO 这个是为4月份的颁奖晚会准备的数据,这里写成了常量,有待优化,应实现动态添加
    tieba_stars = [
      {"tfboys" => 'http://tieba.baidu.com/f?kw=tfboys&ie=utf-8&tp=0'},
      {"陈柏霖" => 'http://tieba.baidu.com/f?ie=utf-8&kw=%E9%99%88%E6%9F%8F%E9%9C%96'},
      {"陈赫" => 'http://tieba.baidu.com/f?kw=%E9%99%88%E8%B5%AB&ie=utf-8&tp=0'},
      {"陈伟霆" => 'http://tieba.baidu.com/f?kw=%E9%99%88%E4%BC%9F%E9%9C%86&ie=utf-8'},
      {"陈晓" => 'http://tieba.baidu.com/f?kw=%E9%99%88%E6%99%93&ie=utf-8&tp=0'},
      {"陈学冬" => 'http://tieba.baidu.com/f?kw=%E9%99%88%E5%AD%A6%E5%86%AC&ie=utf-8&tp=0'},
      {"邓超" => 'http://tieba.baidu.com/f?kw=%E9%82%93%E8%B6%85&ie=utf-8&tp=0'},
      {"范冰冰" => 'http://tieba.baidu.com/f?kw=%E8%8C%83%E5%86%B0%E5%86%B0&ie=utf-8&tp=0'},
      {"冯绍峰" => 'http://tieba.baidu.com/f?kw=%E5%86%AF%E7%BB%8D%E5%B3%B0&ie=utf-8&tp=0'},
      {"高圆圆" => 'http://tieba.baidu.com/f?kw=%E9%AB%98%E5%9C%86%E5%9C%86&ie=utf-8&tp=0'},
      {"韩寒" => 'http://tieba.baidu.com/f?kw=%E9%9F%A9%E5%AF%92&ie=utf-8&tp=0'},
      {"黄渤" => 'http://tieba.baidu.com/f?kw=%E9%BB%84%E6%B8%A4&ie=utf-8&tp=0'},
      {"黄晓明" => 'http://tieba.baidu.com/f?kw=%E9%BB%84%E6%99%93%E6%98%8E&ie=utf-8&tp=0'},
      {"黄轩" => 'http://tieba.baidu.com/f?kw=%E9%BB%84%E8%BD%A9&ie=utf-8&tp=0'},
      {"李易峰" => 'http://tieba.baidu.com/f?kw=%E6%9D%8E%E6%98%93%E5%B3%B0&ie=utf-8&tp=0'},
      {"林更新" => 'http://tieba.baidu.com/f?kw=%E6%9E%97%E6%9B%B4%E6%96%B0&ie=utf-8&tp=0'},
      {"刘诗诗" => 'http://tieba.baidu.com/f?kw=%E5%88%98%E8%AF%97%E8%AF%97&ie=utf-8&tp=0'},
      {"刘亦菲" => 'http://tieba.baidu.com/f?kw=%E5%88%98%E4%BA%A6%E8%8F%B2&ie=utf-8&tp=0'},
      {"鹿晗" => 'http://tieba.baidu.com/f?kw=%E9%B9%BF%E6%99%97&ie=utf-8&tp=0'},
      {"倪妮" => 'http://tieba.baidu.com/f?kw=%E5%80%AA%E5%A6%AE&ie=utf-8&tp=0'},
      {"欧豪" => 'http://tieba.baidu.com/f?kw=%E6%AC%A7%E8%B1%AA&ie=utf-8&tp=0'},
      {"彭于晏" => 'http://tieba.baidu.com/f?kw=%E5%BD%AD%E4%BA%8E%E6%99%8F&ie=utf-8&tp=0'},
      {"汤唯" => 'http://tieba.baidu.com/f?kw=%E6%B1%A4%E5%94%AF&ie=utf-8&tp=0'},
      {"佟丽娅" => 'http://tieba.baidu.com/f?kw=%E4%BD%9F%E4%B8%BD%E5%A8%85&ie=utf-8&tp=0'},
      {"王宝强" => 'http://tieba.baidu.com/f?kw=%E7%8E%8B%E5%AE%9D%E5%BC%BA&ie=utf-8&tp=0'},
      {"吴亦凡" => 'http://tieba.baidu.com/f?kw=%E5%90%B4%E4%BA%A6%E5%87%A1&ie=utf-8&tp=0'},
      {"谢依霖" => 'http://tieba.baidu.com/f?kw=%E8%B0%A2%E4%BE%9D%E9%9C%96&ie=utf-8'},
      {"杨幂" => 'http://tieba.baidu.com/f?kw=%E6%9D%A8%E5%B9%82&ie=utf-8&tp=0'},
      {"杨洋" => 'http://tieba.baidu.com/f?kw=%E6%9D%A8%E6%B4%8B&ie=utf-8&tp=0'},
      {"杨颖" => 'http://tieba.baidu.com/f?kw=angelababy&ie=utf-8&tp=0'},
      {"袁泉" => 'http://tieba.baidu.com/f?kw=%E8%A2%81%E6%B3%89&ie=utf-8&tp=0'},
      {"赵薇" => 'http://tieba.baidu.com/f?kw=%E8%B5%B5%E8%96%87&ie=utf-8&tp=0'},
      {"赵又廷" => 'http://tieba.baidu.com/f?kw=%E8%B5%B5%E5%8F%88%E5%BB%B7&ie=utf-8&tp=0'},
      {"郑恺" => 'http://tieba.baidu.com/f?kw=%E9%83%91%E6%81%BA&ie=utf-8&tp=0'},
      {"钟汉良" => 'http://tieba.baidu.com/f?kw=%E9%92%9F%E6%B1%89%E8%89%AF&ie=utf-8&tp=0'},
      {"周冬雨" => 'http://tieba.baidu.com/f?kw=%E5%91%A8%E5%86%AC%E9%9B%A8&ie=utf-8&tp=0'},
      {"周迅" => 'http://tieba.baidu.com/f?kw=%E5%91%A8%E8%BF%85&ie=utf-8&tp=0'},
      {"李晨" => 'http://tieba.baidu.com/f?kw=%E6%9D%8E%E6%99%A8&ie=utf-8&tp=0'}
    ]

    threads = []
    tieba_stars.each do |star|
      threads   << Thread.new{
        name    = star.keys.first
        link    = star.values.first
        tieba   = MovieSpider::Tieba.new(link,'/Users/x/cookies.txt')
        results = tieba.get_info
        focus   = results # number #关注数
        results = results.last # Array
        tiebas  = []
        results.each do |result|
          info  = {star:name,created:result[:created],author:result[:author],title:result[:title]}
          tieba = TiebaInfo.where(info).first
          info.merge!({reply:result[:comment].to_i,focus:focus.to_i})
          if tieba.present?
            tieba.update_attributes(info)
          else
            tieba = TiebaInfo.create(info)
          end
            tiebas << tieba.id.to_s
        end
        results = [] #释放内存
        generate_tieba_excel(name,tiebas)
        Rails.logger.info " *************** #{star} info generated ***************"
      }      
    end
    threads.each { |thr| thr.join }
  end

  def self.generage_news_excel(result)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '新闻数据' 
    sheet1.row(0).concat %w(电影  标题  内容  链接  媒体 日期  月  天  小时  转载量 转载网络  情感判断)
    row_count = 0
    result.each do |newsid|
      news = Administrivium.find(newsid)
      if news.present?
        time_arr  = news.time.split(/\s+/)
        date      = Date.parse(time_arr.first)
        month     = date.month
        day       = date.day
        date      = date.strftime('%Y年%m月%d日')
        hour      = time_arr.first.split(/:/).first
        rw = [news.keyword,news.title,news.summary,news.link,news.media,date,month,day,hour,news.num,news[:reps].join(','),news.emotion]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_news.xls"
  end

  def self.generage_movie_excel(movies)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '视频数据'
    sheet1.row(0).concat %w(爬取时间  电影名称  地区  类型  导演 主演  简介  视频网站  视频类型  标题 视频地址  播放数  评论数 点赞数 点踩数)
    row_count = 0
    
    movies.each do |movie|
      movie = Movie.find(movie)
      if movie.present?
        rw = [movie.created_at.strftime('%Y年%m月%d日'),movie.title,movie.area,movie.type,movie.director,movie.actor,movie.descript]
        SITE_ARR.each do |s|
          if movie.play_info["#{s}"].present?
            movie.play_info["#{s}"].each do |inf|
              str = '土豆' if s.match(/tudou/)
              str = '优酷' if s.match(/youku/)
              str = '腾讯' if s.match(/tecent/)
              str = '爱奇艺' if s.match(/iqiyi/)
              if inf.present?
                nrw = rw + ["#{str}",inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
                sheet1.row(row_count + 1).replace(nrw)
                row_count += 1
              end
            end
          end
        end

        # if movie.play_info['tudou'].present?
        #   movie.play_info['tudou'].each do |inf|
        #     if inf.present?
        #       nrw = rw + ['土豆',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
        #       sheet1.row(row_count + 1).replace(nrw)
        #       row_count += 1
        #     end
        #   end
        # end
        # if movie.play_info['youku'].present?
        #   movie.play_info['youku'].each do |inf|
        #     if inf.present?
        #       nrw = rw + ['优酷',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
        #       sheet1.row(row_count + 1).replace(nrw)
        #       row_count += 1              
        #     end
        #   end
        # end   
        # if movie.play_info['tecent'].present?
        #   movie.play_info['tecent'].each do |inf|
        #     if inf.present?
        #       nrw = rw + ['腾讯',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
        #       sheet1.row(row_count + 1).replace(nrw)
        #       row_count += 1
        #     end
        #   end
        # end   
        # if movie.play_info['iqiyi'].present?
        #   movie.play_info['iqiyi'].each do |inf|
        #     if inf.present?
        #       nrw = rw + ['爱奇艺',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
        #       sheet1.row(row_count + 1).replace(nrw)
        #       row_count += 1
        #     end
        #   end
        # end                        
      end
    end 
    book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_video.xls"    
  end

  def self.generage_star_excel(hash)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '明星新闻数据'
    sheet1.row(0).concat %w(名称 网站 相关新闻数 平均转载量)
    row_count = 0

    hash.each_pair do |star,arr|
      arr.each_with_index do |k,v|
        rw = [star,v.keys.first,v.values.first[:total],v.values.first[:svg]]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    book.write Rails.root.to_s + '/public/export/' + "stars_data.xls"    
  end

  def self.generate_tieba_excel(star,tiebaids)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '贴吧数据' 
    sheet1.row(0).concat %w(明星 累计关注数  帖子创建时间  回复数  帖子创建者  标题)
    row_count = 0
    tiebaids.each do |tiebaid|
      tieba_info  = TiebaInfo.find(tiebaid)
      if tieba_info.present?
        rw = [tieba_info.star,tieba_info.focus,tieba_info.created,ieba_info.reply,tieba_info.author,tieba_info.title]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    tiebaids = [] #释放内存
    book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today - 1.days).strftime('%F')}_" + "#{star}.xls"
  end



end
