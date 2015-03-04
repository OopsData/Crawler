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
      puts '*************** one movie finished ***************'
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
        baidu  = MovieSpider::Baidu.new(task.keyword,task.start_date,task.end_date)
        data   = baidu.get_news_list
        data.each do |d|
          ns = Administrivium.create(keyword:task.keyword,title:d[:title],link:d[:link],time:d[:time],start_date:task.start_date,end_date:task.end_date,num:d[:num],media:d[:media],reps:d[:reps],summary:d[:summary])
          news << ns.id.to_s
        end
      end      
    end
    generage_news_excel(news)
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
        if movie.play_info['tudou'].present?
          movie.play_info['tudou'].each do |inf|
            if inf.present?
              nrw = rw + ['土豆',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
              sheet1.row(row_count + 1).replace(nrw)
              row_count += 1
            end
          end
        end
        if movie.play_info['youku'].present?
          movie.play_info['youku'].each do |inf|
            if inf.present?
              nrw = rw + ['优酷',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
              sheet1.row(row_count + 1).replace(nrw)
              row_count += 1              
            end
          end
        end   
        if movie.play_info['tecent'].present?
          movie.play_info['tecent'].each do |inf|
            if inf.present?
              nrw = rw + ['腾讯',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
              sheet1.row(row_count + 1).replace(nrw)
              row_count += 1
            end
          end
        end   
        if movie.play_info['iqiyi'].present?
          movie.play_info['iqiyi'].each do |inf|
            if inf.present?
              nrw = rw + ['爱奇艺',inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
              sheet1.row(row_count + 1).replace(nrw)
              row_count += 1
            end
          end
        end                        
      end
    end 
    book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_video.xls"    
  end



end
