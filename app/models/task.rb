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



end
