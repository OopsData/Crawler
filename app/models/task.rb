require 'movie_spider'
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
class Task
  include Mongoid::Document
  include Mongoid::Timestamps



  ENABLE  = 1
  DISABLE = 0
  # SITE_ARR = ['tudou','youku','tecent','iqiyi']


  KWS = {
    "肖凡凡" => %w(肖凡凡 云南妹 黑妹 洗头妹 骚浪贱 学生妹),
    "刘洛汐" => %w(刘落夕 心机婊 心机妹 汐哥 平胸妹 心机表),
    "刘希"   => %w(刘希 刘西 刘熙),
    "聂江伟" => %w(聂江伟 老鬼 队长),
    "张婷媗" => %w(张婷媗 台湾 辣妈 台妹),
    "邓碧莹" => %w(邓碧莹 短发女 广东妹),
    "孙铭"   => %w(孙铭 兵哥),
    "郭道辉" => %w(郭道辉 农民工),
    "刘志轩" => %w(刘志轩 蘑菇头 锅盖头 黑衣男 小四眼 小黑哥),
    "易秋"  => %w(易秋 道士),
    "宋鸽"  => %w(宋鸽 鸽子 博士 哈佛女),
    "丘子建" => %w(丘子建 渣男),
    "谭丽敏" => %w(谭丽敏 老太太 老太婆 上海阿姨 老奶奶),
    "郑虎"  => %w(郑虎 胖子 胖胖),
    "刘富华" => %w(刘富华 鲁迅),
    "韦泽华" => %w(小伟 小宝)
  }


  field :title, type: String
  field :url, type: String
  field :site, type: String
  field :keyword,type:String
  field :start_date,type:String
  field :end_date,type:String
  field :type,type:String,default:'video'
  field :status, type: Integer,default:ENABLE

  # def show_status
  # 	return '正常' if status == 1
  # 	return '终止' if status == 0 
  # end

  # def self.gs_new(url)
  # 	url      = url.gsub(/：：/,'::')
  # 	info_arr = url.split(/::/)
  # 	title    = info_arr.first
  # 	url      = info_arr.last
  # 	site     = guess_site(url)
  # 	self.create(title:title,url:url,site:site)
  # end

  # def self.guess_site(url)
  # 	return '豆瓣' if url.include?('douban')
  # 	return '优酷' if url.include?('youku')
  # 	return '土豆' if url.include?('tudou')
  # 	return '腾讯' if url.include?('qq')
  # 	return '爱奇艺' if url.include?('iqiyi')
  # end

  #视频网站爬虫任务
  # def self.runing_movie_tasks
  #   movies = []

  #   self.where(status:ENABLE,site:'豆瓣').each do |task|
  #     threads = []
  #     douban  =  MovieSpider::Douban.new(task.url)
  #     data    =  douban.get_basic_info
  #     movie   =  Movie.create(title:task.title,director:data[:director],writer:data[:writer],actor:data[:actor],type:data[:type],area:data[:area],language:data[:language],length:data[:length],descript:data[:desc])
  #     movies  << movie.id.to_s
  #     SITE_ARR.each do |site|
  #       threads << Thread.new{
  #         movie.send("runing_#{site}_tasks")
  #       }
  #     end
  #     threads.each { |thr| thr.join }
  #     Rails.logger.info '*************** one movie finished ***************'
  #     # movie.runing_tudou_tasks
  #     # movie.runing_youku_tasks
  #     # movie.runing_tecent_tasks
  #     # movie.runing_iqiyi_tasks
  #   end
  #   generage_movie_excel(movies)
  # end

  # def self.runing_special_keywords
  #   self.where(status:ENABLE,type:'news').each do |task|
  #     end_date = task.end_date
  #     end_date = (Date.today - 1.days).strftime('%Y-%-m-%-d') unless task.end_date.present? 
  #     baidu    = MovieSpider::Baidu.new(task.keyword,task.start_date,end_date)
  #     data     = baidu.get_news
  #     news_ids = []
  #     data[:infos].each do |d|
  #       param = {
  #         keyword:task.keyword,
  #         total:data[:total],
  #         avg:data[:svg],
  #         title:d[:title],
  #         link:d[:link],
  #         media:d[:media],
  #         date:d[:date],
  #         month:d[:month],
  #         day:d[:day],
  #         hour:d[:hour],
  #         relay:d[:relay],
  #         descript:d[:descript],
  #         medias:d[:medias],
  #         start_date:task.start_date,
  #         end_date:task.end_date
  #       }
  #       adm = Administrivium.create(param)
  #       news_ids << adm.id.to_s
  #     end
  #     generage_news_excel(news_ids,task.keyword)
  #   end
  # end


  # def self.runing_news_tasks
  #   news_ids   = []
  #   self.where(status:ENABLE,type:'news').each do |task|
  #     end_date = task.end_date 
  #     # 如果要爬去的某个关键字没有设置截止日期的话,那么就爬取到前一天(爬虫脚本定在每天后半夜爬取)
  #     end_date = (Date.today - 1.days).strftime('%Y-%-m-%-d') unless task.end_date.present? 
  #     baidu    = MovieSpider::Baidu.new(task.keyword,task.start_date,end_date)
  #     data     = baidu.get_news  # data is a hash
  #     data[:infos].each do |d|
  #       param = {
  #         keyword:task.keyword,
  #         total:data[:total],
  #         avg:data[:svg],
  #         title:d[:title],
  #         link:d[:link],
  #         media:d[:media],
  #         date:d[:date],
  #         month:d[:month],
  #         day:d[:day],
  #         hour:d[:hour],
  #         relay:d[:relay],
  #         descript:d[:descript],
  #         medias:d[:medias],
  #         start_date:task.start_date,
  #         end_date:task.end_date
  #       }
  #       adm = Administrivium.create(param)
  #       news_ids << adm.id.to_s
  #     end
  #   end
  #   generage_news_excel(news_ids)
  # end

  #CCTV6 新闻
  # def self.runing_stars_news
  #   stars = ['左耳 电影','万万没想到 电影','港囧 电影','煎饼侠 电影']
  #   threads = []
  #   stars.each do |star|
  #     runing_stars_tasks(star)
  #   end
  # end


  # def self.runing_stars_tasks(file_name=nil)
  #   # stars = ['精绝古城 电影','滚蛋吧 肿瘤君 电影']
  #   stars = ["#{file_name}"]
  #   hash = Hash.new()
  #   stars.each do |s|
  #     star = MovieSpider::Star.new("#{s}",'2014-4-1','2015-3-20')
  #     hash["#{s}"] =  star.get_special_site_news_list
  #   end
  #   generage_star_excel(hash,file_name)
  # end

  # def self.runing_tieba_special_post
  #   tieba      = MovieSpider::Tieba.new(nil,Rails.root.to_s + '/cookies.txt',0)
  #   results    = tieba.special_crawl
  #   book       = Spreadsheet::Workbook.new
  #   sheet1     = book.create_worksheet :name => '贴吧特殊帖'
  #   row_count  = 0
  #   sheet1.row(0).concat %w(作者 作者级别  回复时间  评论数 内容 )
  #   results[:comment_info].each do |res|
  #     rw = [res[:author],res[:level],res[:time],res[:rep],res[:cont]]
  #     sheet1.row(row_count + 1).replace(rw)
  #     row_count += 1
  #   end
  #   book.write Rails.root.to_s + '/public/export/贴吧特殊帖.xls'
  # end

  #CCTV6 贴吧
  # def self.runing_tieba_tasks(is_qqlive=false,limit=0)
  # #TODO 这个是为4月份的颁奖晚会准备的数据,这里写成了常量,有待优化,应实现动态添加
  #   if is_qqlive
  #     tieba_stars = [
  #       {name:"我们15个",link:'http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8',limit:limit}
  #     ]       
  #   else
  #   tieba_stars = [
  #     {name:"我们15个",link:'http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8',limit:limit},
  #     {name:"奇葩说",link:'http://tieba.baidu.com/f?kw=%E5%A5%87%E8%91%A9%E8%AF%B4&ie=utf-8',limit:limit},
  #     {name:"真正男子汉",link:'http://tieba.baidu.com/f?kw=%E7%9C%9F%E6%AD%A3%E7%94%B7%E5%AD%90%E6%B1%89&ie=utf-8',limit:limit}
  #   ]      
  #   end


  #   threads = []

  #   tieba_stars.each do |star_hash|
  #     name  = star_hash[:name]
  #     link  = star_hash[:link]
  #     limit = star_hash[:limit]
  #     threads   << Thread.new{
  #       tieba   = MovieSpider::Tieba.new(link,Rails.root.to_s + '/cookies.txt',limit)
  #       results = tieba.get_info
  #       focus   = results.first # number #关注数
  #       results = results.last # Array
  #       tiebas  = []
  #       results.each do |result|
  #         Rails.logger.info("&&&&&&&&&&&& #{name}  循环入库中 &&&&&&&&&&&&&&&&")
  #         info  = {star:name,created:result[:created],date:result[:created].scan(/\d+-\d+-\d+/).first,author:result[:author],title:result[:title],content:result[:content]}
  #         puts info.inspect
  #         puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
  #         tieba = TiebaInfo.where(info).first
  #         info.merge!({reply:result[:comment].to_i,focus:focus.to_i})
  #         if tieba.present?
  #           tieba.update_attributes(info)
  #         else
  #           tieba = TiebaInfo.create(info)
  #         end
  #           tiebas << tieba.id.to_s
  #       end
  #       results = [] #释放内存
  #       if is_qqlive
  #         generate_tieba_fiveteen_excel(tiebas)
  #       else
  #         generate_tieba_excel(name,tiebas)
  #       end
        
  #       Rails.logger.info " *************** #{name} info generated ***************"
  #     }   
  #   end
  #   threads.each { |thr| thr.join }
  # end

  # def self.generage_news_excel(news_ids,keyword=nil)
  #   book   = Spreadsheet::Workbook.new
  #   sheet1 = book.create_worksheet :name => '新闻数据'
  #   sheet1.row(0).concat %w(关键词  标题  链接  发表媒体  发表日期  月  天  小时  转载数量  平均转载量  总提及量 起始时间  结束时间  内容  转载媒体)
  #   row_count = 0
  #   news_ids.each do |nid|
  #     news = Administrivium.find(nid)
  #     if news.present?
  #       rw = [news.keyword,news.title,news.link,news.media,news.date,news.month,news.day,news.hour,news.relay,news.avg,news.total,news.start_date,news.end_date,news.descript,news.medias.join(',')]
  #       sheet1.row(row_count + 1).replace(rw)
  #       row_count += 1
  #     end
  #   end
  #   if keyword.present?
  #     book.write Rails.root.to_s + '/public/export/' + "#{keyword}" + "_news.xls" 
  #   else
  #     book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_news.xls" 
  #   end
    
  # end

  # def self.generage_movie_excel(movies)
  #   movies = movies.uniq
  #   book   = Spreadsheet::Workbook.new
  #   sheet1 = book.create_worksheet :name => '视频数据'
  #   sheet1.row(0).concat %w(爬取时间  电影名称  地区  类型  导演 主演  简介  视频网站  视频类型  标题 视频地址  播放数  评论数 点赞数 点踩数)
  #   row_count = 0
    
  #   movies.each do |movie|
  #     movie = Movie.find(movie)
  #     if movie.present?
  #       rw = [movie.created_at.strftime('%Y年%m月%d日'),movie.title,movie.area,movie.type,movie.director,movie.actor,movie.descript]
  #       SITE_ARR.each do |s|
  #         if movie.play_info["#{s}"].present?
  #           movie.play_info["#{s}"].each do |inf|
  #             str = '土豆' if s.match(/tudou/)
  #             str = '优酷' if s.match(/youku/)
  #             str = '腾讯' if s.match(/tecent/)
  #             str = '爱奇艺' if s.match(/iqiyi/)
  #             if inf.present?
  #               nrw = rw + ["#{str}",inf['type'],inf['title'],inf['url'],inf['playNum'].to_i,inf['commentNum'].to_i,inf['upNum'].to_i,inf['downNum'].to_i]
  #               sheet1.row(row_count + 1).replace(nrw)
  #               row_count += 1
  #             end
  #           end
  #         end
  #       end                      
  #     end
  #   end 

  #   book.write Rails.root.to_s + '/public/export/' + "#{(Date.today - 1.days).strftime('%F')}" + "_video.xls"    
  # end

  # def self.generage_star_excel(hash,name)
  #   book   = Spreadsheet::Workbook.new
  #   sheet1 = book.create_worksheet :name => '明星新闻数据'
  #   sheet1.row(0).concat %w(名称 网站 相关新闻数 平均转载量 转载量 日期 标题)
  #   row_count = 0

  #   hash.each_pair do |star,arr|
  #     arr.each do |hash|
  #       begin
  #         if hash.keys.first.gsub(/\s+/,'').length < 2
  #           next
  #         end
  #         hash.values.first[:infos].each do |inf|
  #           rw = [star,hash.keys.first,hash.values.first[:total],hash.values.first[:svg],inf[:num],inf[:date],inf[:title]]  
  #           sheet1.row(row_count + 1).replace(rw)
  #           row_count += 1
  #         end
  #       rescue
  #         puts '----------------------  error while generated excel start -----------------------------'
  #         puts star
  #         puts arr.inspect
  #         puts '----------------------  error while generated excel end   -----------------------------'
  #       end
  #     end
  #   end
  #   name = 'stars_data' unless name.present?
  #   book.write Rails.root.to_s + '/public/export/' + "#{name}.xls"    
  # end

  # def self.generate_tieba_excel(star,tiebaids)
  #   book   = Spreadsheet::Workbook.new
  #   sheet1 = book.create_worksheet :name => '贴吧数据' 
  #   sheet1.row(0).concat %w(明星 累计关注数  帖子创建时间  回复数  日均帖子量  帖子平均回复量 帖子创建者  标题)
  #   row_count = 0
  #   #总的发帖天数
  #   total_date  = TiebaInfo.where(star:star).map(&:date).uniq
  #   # 日均帖子量
  #   avg_count   = tiebaids.count / total_date.count.to_f
  #   # 帖子平均回复量
  #   reply_arr   = TiebaInfo.where(star:star).map(&:reply)
  #   reply_count = reply_arr.inject{|sum,x| sum + x }
  #   avg_reply   = reply_count  / tiebaids.count.to_f
  #   tiebaids.each do |tiebaid|
  #     tieba_info  = TiebaInfo.find(tiebaid)
  #     if tieba_info.present?
  #       rw = [tieba_info.star,tieba_info.focus,tieba_info.created,tieba_info.reply,avg_count,avg_reply,tieba_info.author,tieba_info.title]
  #       sheet1.row(row_count + 1).replace(rw)
  #       row_count += 1
  #     end
  #   end
  #   tiebaids = [] #释放内存
  #   # book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today - 1.days).strftime('%F')}_" + "#{star}.xls"
  #   book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today).strftime('%F')}_" + "#{star}.xls"
  # end


  # def self.generate_tieba_fiveteen_excel(tiebaids)
  #   book   = Spreadsheet::Workbook.new
  #   sheet1 = book.create_worksheet :name => '贴吧数据' 
  #   sheet1.row(0).concat %w(姓名 关键词  帖子量  帖子回复量 帖子平均回复量)
  #   row_count = 0

  #   KWS.each do |name,arr|
  #     count = 0
  #     reply = 0
  #     tiebaids.each do |tiebaid|
  #       tieba_info  = TiebaInfo.find(tiebaid)
  #       arr.each do |kwd|
  #         if (tieba_info.content.match(/#{kwd}/) || tieba_info.title.match(/#{kwd}/))
  #           count += 1
  #           reply += tieba_info.reply.to_i
  #         end
  #       end
  #     end
  #     rw = [name,arr.join(';'),count,reply,reply.to_f / count]
  #     sheet1.row(row_count + 1).replace(rw)
  #     row_count += 1
  #   end

  #   tiebaids = [] #释放内存
  #   book.write Rails.root.to_s + '/public/export/' + "贴吧_#{(Date.today).strftime('%F')}_15个.xls"
  # end



  # =========================

  # 《我们十五个》饭团爬虫任务
  def self.runing_fifteen_fantuan_tasks
    fantuan  = MovieSpider::Fantuan.new
    results  = fantuan.start_crawl
    results.each do |result|
      Fantuan.create(result)
    end
    # 导出原始数据excel
    generate_fantuan_original_data_excel
    #导出统计数据excel
    generate_fantuan_fifteen_statistics_data_excel
    #导出云词数据excel
    generate_fantuan_cloud_words_excel
  end

  #《我们十五个》腾讯视频直播弹幕任务
  def self.runing_fifteen_qqlive_tasks
    qqlive  = MovieSpider::Qqlive.new
    results = qqlive.start_crawl
    results.each do |result|
      qlive = Qqlive.where(cmt_id:result[:cmt_id]).first
      unless qlive.present?
        Qqlive.create(result)
      else
        Rails.logger.info '已经存在。。。。。。。。。。。。'
      end
    end
  end

  #《我们十五个》贴吧爬取任务
  def self.runing_fifteen_tieba_tasks(limit=1500)
    link_info = {name:"我们15个",link:'http://tieba.baidu.com/f?kw=%E6%88%91%E4%BB%AC15%E4%B8%AA&ie=utf-8',limit:limit}
    name      = link_info[:name]
    link      = link_info[:link]
    limit     = link_info[:limit]
    tieba     = MovieSpider::Tieba.new(link,Rails.root.to_s + '/cookies.txt',limit)
    res       = tieba.start_crawl
    info      = {name:name,focus:res[:focus],results:res[:results]}

    TiebaInfo.create(info)
    #导出原始数据excel
    generate_tieba_original_data_excel(name)
    #导出统计数据excel
    generate_tieba_fifteen_statistics_data_excel(name)
    #导出原始数据的所有文本 作为云词用
    generate_tieba_cloud_words_excel(name)
  end 

  # 导出贴吧原始数据
  # name 要导出的贴吧名
  # td   日期 表示要导出某天抓取的数据
  def self.generate_tieba_original_data_excel(name,td=nil)
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end

    info   = TiebaInfo.where(:name => name,:created_at.gte => td,:created_at.lt => td + 1.days).first
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "贴吧原始数据_累计关注数#{info[:focus]}"
    sheet1.row(0).concat %w(作者  发帖日期  发帖小时数  发帖分钟数  回帖数  标题  内容  回帖作者  回帖时间  回帖内容  评论作者 评论时间  评论内容 )
    row_count = 0

    info.results.each do |tid,result|
      basic = result[:basic]
      posts = result[:posts]
      d,h   = basic[:date].split(' ')
      h,m   = h.split(':')
      rw    = [basic[:author][:name].to_s,d,h.to_i,m.to_i,basic[:reply].to_i,basic[:title].to_s,basic[:content].to_s,'','','','','','']
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1
      result[:posts].each do |post|
        rw = ['','','','','','','',post[:author].to_s,post[:date],post[:content].to_s,'','','']
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1

        if post[:comment_num] > 0 
          post[:comments].each do |cmt|
            rw = ['','','','','','','','','','',cmt[:author].to_s,cmt[:date],cmt[:content].to_s]
            sheet1.row(row_count + 1).replace(rw)
            row_count += 1
          end
        end
      end
      row_count += 1
    end
    book.write Rails.root.to_s + '/public/export/' + "贴吧_#{name}_原始数据_#{td}.xls"
  end

  # 导出贴吧原始文本作为云词词库
  # name 要导出的贴吧名
  # td 日期  表示要导出某天抓取的数据
  def self.generate_tieba_cloud_words_excel(name,td=nil)
    if td
      td    = Date.parse(td)
    else
      td    = Date.today
    end
    info    = TiebaInfo.where(:name => name,:created_at.gte => td,:created_at.lt => td + 1.days).first
    book    = Spreadsheet::Workbook.new 
    sheet1  = book.create_worksheet :name => "贴吧云词文本"
    sheet1.row(0).concat %w(原始文本)
    row_count = 0  
    info.results.each do |tid,result|
      basic = result[:basic]
      posts = result[:posts]
      title =  basic[:title].strip
      if title.length > 0
        rw    = [title]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
      content = basic[:content].strip
      if content.length > 0
        rw    = [content]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end 
      posts.each do |post|
        content =  post[:content].strip
        if content.length > 0
          rw = [content]
          sheet1.row(row_count + 1).replace(rw)
          row_count += 1
        end
        # 评论内容没有添加到云词文本
        # if post[:comment_num].to_i > 0
        #   post[:comments].each do |cmt|
        #     content = cmt[:content].strip
        #     if content.length > 0
        #       rw = [content]
        #       sheet1.row(row_count + 1).replace(rw)
        #       row_count += 1
        #     end
        #   end
        # end
      end
    end
    book.write Rails.root.to_s + '/public/export/' + "贴吧_#{name}_云词数据_#{td}.xls"
  end

  # 导出我们15个关键词数据
  # name 要导出的贴吧名
  # td 日期 表示要导出某天抓取的数据
  def self.generate_tieba_fifteen_statistics_data_excel(name,td=nil)
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end
    info   = TiebaInfo.where(:name => name,:created_at.gte => td,:created_at.lt => td + 1.days).first
    book   = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "我们15个关键词数据"   
    sheet1.row(0).concat %w(姓名 关键词  主题量  回复帖子量  平均回复量  帖子评论量)
    row_count = 0

    KWS.each do |name,arr|
      arr.each do |kwd|
        theme_count     = 0 # 主题量
        post_count      = 0 # 回复帖子量
        comment_count   = 0 # 帖子评论量
        info.results.each do |tid,result|
          basic         = result[:basic]
          theme_title   = basic[:title]
          theme_content = basic[:content] 
          posts         = result[:posts]
          if theme_title.match(/#{kwd}/)
            theme_count += 1
          elsif theme_content.match(/#{kwd}/)
            theme_count += 1
          end
          posts.each do |post|
            if post[:content].match(/#{kwd}/)
              post_count += 1
            end
            if post[:comment_num].to_i > 0
              post[:comments].each do |cmt|
                if cmt[:content].match(/#{kwd}/)
                  comment_count += 1
                end
              end
            end
          end
        end
        rw = [name,kwd,theme_count,post_count,post_count.to_f / theme_count,comment_count]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
      book.write Rails.root.to_s + '/public/export/' + "贴吧_我们15个_统计数据_#{td.strftime('%F')}.xls"
    end
  end

  # 导出饭团原始数据
  # name 要导出的数据名称
  # td 日期 表示要导出某天抓取到的数据
  def self.generate_fantuan_original_data_excel(name=nil,td=nil)
    # name 暂时还没有用上
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end    
    fantuans = Fantuan.where(:created_at.gte => td,:created_at.lt => td + 1.days)
    book     = Spreadsheet::Workbook.new
    sheet1   = book.create_worksheet :name => "饭团原始数据"
    sheet1.row(0).concat %w(发帖日期  发帖人  回帖数  点赞数  标题   内容  评论时间   评论人  评论内容) 
    row_count = 0  
    fantuans.each do |ft|
      rw = [ft.time.strftime('%Y-%m-%d %H:%I:%S'),ft.author,ft.orireplynum,ft.up,ft.title,ft.content,'','','']
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1   
      ft.comments.each do |cmt|
        rw = ['','','','','','',cmt[:time].strftime('%Y-%m-%d %H:%I:%S'),cmt[:nick],cmt[:content]]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end   
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_原始数据_#{td.strftime('%F')}.xls"
  end

  # 导出 我们15个分析数据
  # td  日期 表示要导出某天抓取到的数据
  def self.generate_fantuan_fifteen_statistics_data_excel(td=nil)
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end
    fantuans  = Fantuan.where(:created_at.gte => td,:created_at.lt => td + 1.days)
    book      = Spreadsheet::Workbook.new
    sheet1    = book.create_worksheet :name => '饭团数据'
    row_count = 0
    sheet1.row(0).concat %w(姓名  关键词 帖子量 帖子回复量 平均回复量)

    KWS.each do |name,arr|
      post_count = 0
      repl_count = 0
      # 如果一个帖子的标题或者内容或者里面的评论中包含关键词，则改贴就记录在内
      arr.each do |kwd|
        fantuans.each do |ft|
          if ft.title.match(/#{kwd}/) || ft.content.match(/#{kwd}/)
            post_count += 1
            repl_count += ft.comments.length
          else
            match = false
            ft.comments.map{|e| e[:content]}.each do |cnt|
              if cnt.match(/#{kwd}/)
                match = true
                break
              end
            end
            if match 
              post_count += 1
              repl_count += ft.comments.length
            end
          end
        end
        rw = [name,kwd,post_count,repl_count,repl_count.to_f / post_count]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1        
      end
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_我们15个_统计数据_#{td.strftime('%F')}.xls"
  end
  # 导出饭团云词数据
  # td  日期 表示要导出某天抓取到的数据
  def self.generate_fantuan_cloud_words_excel(td)
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end
    fantuans  = Fantuan.where(:created_at.gte => td,:created_at.lt => td + 1.days) 
    book      = Spreadsheet::Workbook.new
    sheet1    = book.create_worksheet :name => '饭团云词数据'
    row_count = 0
    sheet1.row(0).concat %w(云词文本)
    fantuans.each do |ft|
      rw = [ft.title]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1 
      rw = [ft.content]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1 
      # 评论内容没有加入到云词文本内
      # ft.comments.each do |cmt|
      #   rw = [cmt[:content]]
      #   sheet1.row(row_count + 1).replace(rw)
      #   row_count += 1 
      # end         
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_云词数据_#{td.strftime('%F')}.xls"
  end

  # 导出 我们15个 腾讯视频直播 相关数据
  def self.export_qqlive_datas_excel(td)
    if td
      td   = Date.parse(td)
    else
      td   = Date.today
    end
    datas  = Qqlive.where(:created_at.gte => td,:created_at.lt => td + 1.days).to_a
    export_qqlive_original_excel(td,datas)
    export_qqlive_statistics_data_excel(td,datas)
    export_qqlive_cloud_words(td,datas)
  end

  # 导出 我们15个 腾讯视频直播原始数据
  def self.export_qqlive_original_excel(td,datas)
    book      = Spreadsheet::Workbook.new
    sheet1    = book.create_worksheet :name => '弹幕原始数据'
    row_count = 0
    sheet1.row(0).concat %w(时间 评论人  点赞数  内容)
    row_count = 0
    datas.each do |data|
      rw = [data.time.strftime('%Y-%m-%d %H:%I:%S'), data.nick,data.up.to_i,data.cont]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1       
    end
    book.write Rails.root.to_s + '/public/export/' + "弹幕_原始数据_#{td.strftime('%F')}.xls"
  end

  # 导出 我们15个 腾讯视频直播统计数据
  def self.export_qqlive_cloud_words(td,datas)
    book      = Spreadsheet::Workbook.new
    sheet1    = book.create_worksheet :name => '弹幕统计数据'
    row_count = 0
    sheet1.row(0).concat %w(云词文本)
    row_count = 0
    datas.each do |data|
      rw = [data.cont]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1       
    end
    book.write Rails.root.to_s + '/public/export/' + "弹幕_云词数据_#{td.strftime('%F')}.xls"  
  end

  # 导出 我们15个 腾讯视频直播统计数据
  def self.export_qqlive_statistics_data_excel(td,datas)
    book      = Spreadsheet::Workbook.new
    sheet1    = book.create_worksheet :name => '弹幕云词数据'
    row_count = 0
    sheet1.row(0).concat %w(姓名  关键词  频次)
    row_count = 0
    KWS.each do |name,arr|
      arr.each do |kwd|
        count = 0
        datas.each do |data|
          if data.cont.match(/#{kwd}/)
            count += 1
          end
        end
        rw = [name,kwd,count]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1
      end
    end
    book.write Rails.root.to_s + '/public/export/' + "弹幕_统计数据_#{td.strftime('%F')}.xls"  
  end
end
