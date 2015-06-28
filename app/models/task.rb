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

  def self.runing_fantuan_tasks
    fantuan  = MovieSpider::Fantuan.new
    results  = fantuan.start_crawl
    results.each do |result|
      Fantuan.create(result)
    end
    generate_fantuan_excel(results)
  end

  def self.runing_qqlive_tasks
    qqlive  = MovieSpider::Qqlive.new
    results = qqlive.start_crawl
    results.each do |result|
      qlive = Qqlive.where(cmt_id:result[:cmt_id]).first
      unless qlive.present?
        Qqlive.create(result)
      end
    end
  end

  def self.runing_special_keywords
    self.where(status:ENABLE,type:'news').each do |task|
      end_date = task.end_date
      end_date = (Date.today - 1.days).strftime('%Y-%-m-%-d') unless task.end_date.present? 
      baidu    = MovieSpider::Baidu.new(task.keyword,task.start_date,end_date)
      data     = baidu.get_news
      news_ids = []
      data[:infos].each do |d|
        param = {
          keyword:task.keyword,
          total:data[:total],
          avg:data[:svg],
          title:d[:title],
          link:d[:link],
          media:d[:media],
          date:d[:date],
          month:d[:month],
          day:d[:day],
          hour:d[:hour],
          relay:d[:relay],
          descript:d[:descript],
          medias:d[:medias],
          start_date:task.start_date,
          end_date:task.end_date
        }
        adm = Administrivium.create(param)
        news_ids << adm.id.to_s
      end
      generage_news_excel(news_ids,task.keyword)
    end
  end


  def self.runing_news_tasks
    news_ids   = []
    self.where(status:ENABLE,type:'news').each do |task|
      end_date = task.end_date 
      # 如果要爬去的某个关键字没有设置截止日期的话,那么就爬取到前一天(爬虫脚本定在每天后半夜爬取)
      end_date = (Date.today - 1.days).strftime('%Y-%-m-%-d') unless task.end_date.present? 
      baidu    = MovieSpider::Baidu.new(task.keyword,task.start_date,end_date)
      data     = baidu.get_news  # data is a hash
      data[:infos].each do |d|
        param = {
          keyword:task.keyword,
          total:data[:total],
          avg:data[:svg],
          title:d[:title],
          link:d[:link],
          media:d[:media],
          date:d[:date],
          month:d[:month],
          day:d[:day],
          hour:d[:hour],
          relay:d[:relay],
          descript:d[:descript],
          medias:d[:medias],
          start_date:task.start_date,
          end_date:task.end_date
        }
        adm = Administrivium.create(param)
        news_ids << adm.id.to_s
      end
    end
    generage_news_excel(news_ids)
  end

  #CCTV6 新闻
  def self.runing_stars_news
    #stars  = ['左耳 电影','横冲直撞好莱坞 电影','老炮儿 电影','《报告老板》 电影','《卧虎藏龙2》','三打白骨精 电影','《美人鱼》 电影','澳门风云3 电影','叶问3 电影','《长城》 电影']
    stars = ['左耳 电影','万万没想到 电影','港囧 电影','煎饼侠 电影']
    threads = []
    stars.each do |star|
      runing_stars_tasks(star)
    end
  end


  def self.runing_stars_tasks(file_name=nil)
    #stars  = ['tfboys','陈柏霖','陈赫','陈伟霆','陈晓','陈学冬','邓超','范冰冰','冯绍峰','高圆圆','韩寒','黄渤','黄晓明','黄轩','李易峰','林更新','刘诗诗','刘亦菲','鹿晗','倪妮','欧豪','彭于晏','汤唯','佟丽娅','王宝强','吴亦凡','谢依霖','杨幂','杨洋','AngelaBaby','袁泉','赵薇','赵又廷','郑恺','钟汉良','周冬雨','周迅','井柏然','李晨']
    #stars  = ['奔跑吧兄弟 电影','雪岭熊风 ','爸爸去哪儿2 大电影','智取威虎山 电影','十万个冷笑话 电影  ','匆匆那年 电影','分手大师 电影','归来 张艺谋','归来 巩俐','归来 陈道明','归来 张慧雯','狼图腾 电影','小时代3 电影  ','同桌的你 电影','老男孩2 电影  ','澳门风云2 电影','归来 电影','老男孩之猛龙过江 电影','后会无期 电影']
    #stars  = ['何以笙箫默 电影','万物生长 电影','左耳 电影','栀子花开 电影','寻龙诀 电影','道士下山 电影','三少爷的剑 电影','万万没想到 电影','报告老板 电影','废柴兄弟 电影','摆渡人 电影','滚蛋吧肿瘤君 电影','精古绝城之鬼吹灯 电影','酒国英雄之摆渡人 电影','捉妖记 电影','小时代4 电影','港囧 电影','华丽上班族 电影','煎饼侠 电影']
    # stars = ['《归来》 巩俐','《归来》 张慧雯','《归来》 张艺谋','《归来》 电影','《归来》 陈道明']
    # stars = ['精绝古城 电影','滚蛋吧 肿瘤君 电影']
    stars = ["#{file_name}"]
    hash = Hash.new()
    stars.each do |s|
      star = MovieSpider::Star.new("#{s}",'2014-4-1','2015-3-20')
      hash["#{s}"] =  star.get_special_site_news_list
    end
    generage_star_excel(hash,file_name)
  end
  #CCTV6 贴吧
  def self.runing_tieba_tasks
  #TODO 这个是为4月份的颁奖晚会准备的数据,这里写成了常量,有待优化,应实现动态添加

    tieba_stars = [
      {name:"我们15个",link:'http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8',limit:0},
      {name:"奇葩说",link:'http://tieba.baidu.com/f?kw=%E5%A5%87%E8%91%A9%E8%AF%B4&ie=utf-8',limit:0},
      {name:"真正男子汉",link:'http://tieba.baidu.com/f?kw=%E7%9C%9F%E6%AD%A3%E7%94%B7%E5%AD%90%E6%B1%89&ie=utf-8',limit:0}
    ]

    threads = []

    tieba_stars.each do |star_hash|
      name  = star_hash[:name]
      link  = star_hash[:link]
      limit = star_hash[:limit]
      threads   << Thread.new{
        tieba   = MovieSpider::Tieba.new(link,Rails.root.to_s + '/cookies.txt',limit)
        results = tieba.get_info
        focus   = results.first # number #关注数
        results = results.last # Array
        tiebas  = []
        results.each do |result|
          Rails.logger.info("&&&&&&&&&&&& #{name}  循环入库中 &&&&&&&&&&&&&&&&")
          info  = {star:name,created:result[:created],date:result[:created].scan(/\d+-\d+-\d+/).first,author:result[:author],title:result[:title]}
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
        Rails.logger.info " *************** #{name} info generated ***************"
      }   
    end
    threads.each { |thr| thr.join }
  end

  def self.generage_news_excel(news_ids,keyword=nil)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '新闻数据'
    sheet1.row(0).concat %w(关键词  标题  链接  发表媒体  发表日期  月  天  小时  转载数量  平均转载量  总提及量 起始时间  结束时间  内容  转载媒体)
    row_count = 0
    news_ids.each do |nid|
      news = Administrivium.find(nid)
      if news.present?
        rw = [news.keyword,news.title,news.link,news.media,news.date,news.month,news.day,news.hour,news.relay,news.avg,news.total,news.start_date,news.end_date,news.descript,news.medias.join(',')]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    if keyword.present?
      book.write Rails.root.to_s + '/public/export/' + "#{keyword}" + "_news.xls" 
    else
      book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_news.xls" 
    end
    
  end

  def self.generage_movie_excel(movies)
    movies = movies.uniq
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
      end
    end 

    book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_video.xls"    
  end

  def self.generage_star_excel(hash,name)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '明星新闻数据'
    sheet1.row(0).concat %w(名称 网站 相关新闻数 平均转载量 转载量 日期 标题)
    row_count = 0

    hash.each_pair do |star,arr|
      arr.each do |hash|
        begin
          if hash.keys.first.gsub(/\s+/,'').length < 2
            next
          end
          hash.values.first[:infos].each do |inf|
            rw = [star,hash.keys.first,hash.values.first[:total],hash.values.first[:svg],inf[:num],inf[:date],inf[:title]]  
            sheet1.row(row_count + 1).replace(rw)
            row_count += 1
          end
        rescue
          puts '----------------------  error while generated excel start -----------------------------'
          puts star
          puts arr.inspect
          puts '----------------------  error while generated excel end   -----------------------------'
        end
      end
    end
    name = 'stars_data' unless name.present?
    book.write Rails.root.to_s + '/public/export/' + "#{name}.xls"    
  end

  def self.generate_tieba_excel(star,tiebaids)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '贴吧数据' 
    sheet1.row(0).concat %w(明星 累计关注数  帖子创建时间  回复数  日均帖子量  帖子平均回复量 帖子创建者  标题)
    row_count = 0
    #总的发帖天数
    total_date  = TiebaInfo.where(star:star).map(&:date).uniq
    # 日均帖子量
    avg_count   = tiebaids.count / total_date.count.to_f
    # 帖子平均回复量
    reply_arr   = TiebaInfo.where(star:star).map(&:reply)
    reply_count = reply_arr.inject{|sum,x| sum + x }
    avg_reply   = reply_count  / tiebaids.count.to_f
    tiebaids.each do |tiebaid|
      tieba_info  = TiebaInfo.find(tiebaid)
      if tieba_info.present?
        rw = [tieba_info.star,tieba_info.focus,tieba_info.created,tieba_info.reply,avg_count,avg_reply,tieba_info.author,tieba_info.title]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    tiebaids = [] #释放内存
    # book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today - 1.days).strftime('%F')}_" + "#{star}.xls"
    book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today).strftime('%F')}_" + "#{star}.xls"
  end


  def self.generate_fantuan_excel(results)
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '饭团数据'
    sheet1.row(0).concat %w(标题 发帖时间  作者 点赞量 评论量  内容)
    row_count = 0
    results.each do |result|
      rw = [result['title'],result['time'],result['author'],result['up'],result['orireplynum'],result['content']]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_#{(Date.today).strftime('%F')}.xls"

  end

  def self.generate_qqlive_excel
    td  = Date.today.strftime('%F')
    datas = Qqlive.all.select{|e| e.time.strftime('%F') == Time.now.strftime('%F') }
    tmp_datas = []
    datas.each_slice(50000) do |qqlives|
      tmp_datas << qqlives
    end

    tmp_datas.each_with_index do | datas,idx|
      book   = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => '弹幕数据'
      row_count = 0
      sheet1.row(0).concat %w( 发帖时间 作者  评论量 内容)
      datas.each do |qqlive|
        rw = [qqlive.time.strftime('%Y-%m-d% %H:%I:%S'),qqlive.nick,qqlive.up,qqlive.cont]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
      book.write Rails.root.to_s + '/public/export/' + "弹幕_#{td}_#{idx + 1}.xls"
    end
  end


end
