require 'spreadsheet'
require 'movie_spider'
Spreadsheet.client_encoding = 'UTF-8'
class Fantuan
  include Mongoid::Document
  include Mongoid::Timestamps
  field :postid,type:String
  field :title,type:String
  field :content,type:String
  field :orireplynum,type:Integer
  field :up,type:Integer
  field :author,type:String
  field :gender,type:Integer
  field :region,type:String
  field :time,type:DateTime
  field :comments,type:Array

  index({ title: 1 }, { background: true } )
  index({ postid: 1 }, { background: true } )

  # 抓取历史记录
  def self.crawl_history_data
    runing_fantuan_tasks
  end

  # 最多抓取400页的帖子
  # 每页包含24个帖子
  def self.crawl_yesterday_data(max_page=399)
    runing_fantuan_tasks(max_page)
    from = to = (Date.today - 1.days).strftime('%F')
    import_reports(from,to)
  end

  def self.runing_fantuan_tasks(limit=nil)
    fantuan  = MovieSpider::Fantuan.new(limit)
    results  = fantuan.start_crawl
    results.each do |result|
      save_history_data(result)
    end
  end


  def self.save_history_data(result)
    postid = result['postid']
    url = "http://localhost:9200/crawler/fantuan/#{postid}"
    result.merge!({name:'我们15个'})
    data = JSON.generate(result)
    begin
      RestClient.put "#{url}", data, {:content_type => :json}
    rescue
      puts '保存出错-------------'
    end     
  end


  def self.search_by_name(from,name)
    uri   = URI('http://localhost:9200/crawler/fantuan/_search')
    query = {from:from,size:1000,q:"name:#{name}"}
    uri.query = URI.encode_www_form(query)
    res   = JSON.parse(Net::HTTP.get_response(uri).body)
    res   = res['hits']['hits']
    return res
  end


  # 导出指定时间段的数据
  def self.import_reports(from,to)
    name = '我们15个'
    opt = {}
    opt[:people_kwds],opt[:entangle_kws],opt[:warn_kwds],opt[:program_kwds],opt[:story_kwds],opt[:disport_kwds],opt[:feature_kwds] = TiebaTheme.get_key_words(name)
    opt.merge!({from:from,to:to,name:name})
    generate_keyword_excel(opt)
    generate_people_excel(opt)
    generate_increment_excel(opt)       
  end

  def self.get_total_count(name)
    uri   = URI('http://localhost:9200/crawler/fantuan/_count')
    query = {q:"name:#{name}"}
    uri.query = URI.encode_www_form(query)
    res   = JSON.parse(Net::HTTP.get_response(uri).body)
    return res['count'].to_i
  end


  def self.generate_keyword_excel(opt)
    book   = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "我们15个_数据"
    sheet1.row(0).concat %w(节目名称  发帖时间  人物关键词  卷入关键词  预警关键词  节目关键词  剧情关键词  娱乐关键词  人物特征关键词  主题标题  主题内容  正负判断 回帖量) 
    row_count = 0 
    from   = opt[:from]
    to     = opt[:to]
    count = self.get_total_count(opt[:name])
    (0..count).to_a.each_slice(1000) do |a|
      f       = a.first
      results = self.search_by_name(f,opt[:name]) 
      results.each do |post|
        source  = post['_source']
        date    = source['time'].split(' ').first 
        title   = source['title']
        cont    = source['content']
        reply   = source['orireplynum']
        begin
          if date.present?
            if date >= from && date <= to
              people = '' # 人物关键词
              if opt[:people_kwds]
                opt[:people_kwds].each do |name,arr|
                  kwd_str = []
                  arr.each do |kwd|
                    if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                      kwd_str << kwd
                    end
                  end
                  if kwd_str.length > 0
                    people += "#{name}=>(#{kwd_str.join(';')})  "
                  end
                end
              end
              entangle = '' # 卷入关键词
              if opt[:entangle_kws]
                opt[:entangle_kws].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    entangle += "  #{kwd}"
                  end
                end
              end
              warn = '' #预警关键词
              if opt[:warn_kwds]
                opt[:warn_kwds].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    warn += "  #{kwd}"
                  end
                end        
              end
              program = '' #节目关键词
              if opt[:program_kwds]
                opt[:program_kwds].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    program += "  #{kwd}"
                  end
                end         
              end
              story = '' # 剧情关键词
              if opt[:story_kwds]
                opt[:story_kwds].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    story += "  #{kwd}"
                  end
                end          
              end
              disport = '' #娱乐关键词
              if opt[:disport_kwds]
                opt[:disport_kwds].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    disport += "  #{kwd}"
                  end
                end          
              end
              feature = ''
              if opt[:feature_kwds]
                opt[:feature_kwds].each do |kwd|
                  if title.to_s.match(/#{kwd}/) || cont.to_s.match(/#{kwd}/)
                    feature += "  #{kwd}"
                  end
                end           
              end
              begin
                judge_value = TiebaTheme.get_feeling_value(cont)
              rescue
                judge_value = 0.0
              end
              rw = [opt[:name],date,people,entangle,warn,program,story,disport,feature,title,cont,judge_value,reply.to_i]
              sheet1.row(row_count + 1).replace(rw)
              row_count += 1         
            end        
          end
        rescue
          puts "error:#{$!} at:#{$@}"
          puts '=============================================================================='
        end
      end     
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_关键词数据_#{opt[:from]}_#{opt[:to]}.xls"    
  end

  def self.generate_people_excel(opt)
    if opt[:people_kwds]
      book   = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "#{opt[:name]}数据"
      sheet1.row(0).concat %w(日期  人物名称 回帖子量 评论量)
      row_count = 0
      themes = [] # 盛放主题
      posts  = [] # 盛放回帖
      count = self.get_total_count(opt[:name])
      (0..count).to_a.each_slice(1000) do |a|
        f       = a.first
        results = self.search_by_name(f,opt[:name]) 
        results.each do |post|
          source  = post['_source']
          date    = source['time'].split(' ').first 
          title   = source['title']
          cont    = source['content']
          opt[:people_kwds].each do |name,kws|
            kws.each do |kw|
              if title.match(/#{kw}/) || cont.match(/#{kw}/)
                if date
                  themes << {date:date,name:name}
                end
              end
              if source['comments'].length > 0 
                source['comments'].each do |cmt|
                  cont = cmt['content'].to_s
                  if cont.match(/#{kw}/)
                    if cmt['time']
                      date = cmt['time'].split(' ').first 
                      posts << {date:date,name:name}
                    end
                  end
                end
              end
            end            
          end
        end
      end

      from    = Date.parse(opt[:from])      
      to      = Date.parse(opt[:to])
      results = {}
      from.upto(to) do |date|
        opt[:people_kwds].each do |name,kws|
          theme_count = themes.select{|theme| theme[:date] == date.strftime('%F') && theme[:name] == name}.length
          post_count  = posts.select{|post| post[:date] == date.strftime('%F') && post[:name] == name}.length
          results["#{date}_#{name}"] = {theme_count:theme_count,post_count:post_count}
        end
      end

      results.each do |key,value|
        dat = key.split('_').first 
        nam = key.split('_').last
        rw = [dat,nam,value[:theme_count],value[:post_count]]
        sheet1.row(row_count + 1).replace(rw)
        row_count += 1        
      end
      book.write Rails.root.to_s + '/public/export/' + "饭团_人物统计_#{from.strftime('%F')}_#{to.strftime('%F')}.xls"
    end      
  end

  def self.generate_increment_excel(opt)
    book    = Spreadsheet::Workbook.new 
    sheet1  = book.create_worksheet :name => "#{opt[:name]}数据"
    sheet1.row(0).concat %w(日期  新增主题量  新增评论量)
    row_count    = 0
    theme_result = {}
    post_result  = {}
    from         = opt[:from]
    to           = opt[:to]

    count = self.get_total_count(opt[:name])
    (0..count).to_a.each_slice(1000) do |a|
      f       = a.first
      results = self.search_by_name(f,opt[:name]) 
      results.each do |post|
        post = post['_source']
        if post['time']
          theme_date = post['time'].split(' ').first
          if theme_date >= from && theme_date <= to 
           if theme_result["#{theme_date}"]
              theme_result["#{theme_date}"] += 1
           else
              theme_result["#{theme_date}"] = 1
           end  
          end
        end
        if post['comments'].length > 0 
          post['comments'].each do |cmt|
            cmt_date = cmt['time'].split(' ').first 
            if cmt_date >= from && cmt_date <= to 
              if post_result["#{cmt_date}"]
                post_result["#{cmt_date}"] += 1
              else
                post_result["#{cmt_date}"]  = 1
              end
            end            
          end
        end
      end
    end

    dates = theme_result.keys.concat(post_result.keys).uniq.sort
    dates.each do |date|
      rw = [date,theme_result["#{date}"].to_i,post_result["#{date}"].to_i]
      sheet1.row(row_count + 1).replace(rw)
      row_count += 1
    end
    book.write Rails.root.to_s + '/public/export/' + "饭团_增量数据_#{from}_#{to}.xls"     
  end


end