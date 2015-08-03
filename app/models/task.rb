require 'movie_spider'
require 'spreadsheet'
require 'net/http'
require 'uri'
Spreadsheet.client_encoding = 'UTF-8'
class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  #《我们十五个》腾讯视频直播弹幕任务
  # def self.runing_fifteen_qqlive_tasks
  #   qqlive  = MovieSpider::Qqlive.new
  #   results = qqlive.start_crawl
  #   results.each do |result|
  #     qlive = Qqlive.where(cmt_id:result[:cmt_id]).first
  #     unless qlive.present?
  #       Qqlive.create(result)
  #     else
  #       Rails.logger.info '已经存在。。。。。。。。。。。。'
  #     end
  #   end
  # end

  # 导出 我们15个 腾讯视频直播 相关数据
  # def self.export_qqlive_datas_excel(td)
  #   if td
  #     td   = Date.parse(td)
  #   else
  #     td   = Date.today
  #   end
  #   datas  = Qqlive.where(:created_at.gte => td,:created_at.lt => td + 1.days).to_a
  #   export_qqlive_original_excel(td,datas)
  #   export_qqlive_statistics_data_excel(td,datas)
  #   export_qqlive_cloud_words(td,datas)
  # end

  # 导出 我们15个 腾讯视频直播原始数据
  # def self.export_qqlive_original_excel(td,datas)
  #   book      = Spreadsheet::Workbook.new
  #   sheet1    = book.create_worksheet :name => '弹幕原始数据'
  #   row_count = 0
  #   sheet1.row(0).concat %w(时间 评论人  点赞数  内容)
  #   row_count = 0
  #   datas.each do |data|
  #     rw = [data.time.strftime('%Y-%m-%d %H:%I:%S'), data.nick,data.up.to_i,data.cont]
  #     sheet1.row(row_count + 1).replace(rw)
  #     row_count += 1       
  #   end
  #   book.write Rails.root.to_s + '/public/export/' + "弹幕_原始数据_#{td.strftime('%F')}.xls"
  # end

  # 导出 我们15个 腾讯视频直播统计数据
  # def self.export_qqlive_cloud_words(td,datas)
  #   book      = Spreadsheet::Workbook.new
  #   sheet1    = book.create_worksheet :name => '弹幕统计数据'
  #   row_count = 0
  #   sheet1.row(0).concat %w(云词文本)
  #   row_count = 0
  #   datas.each do |data|
  #     rw = [data.cont]
  #     sheet1.row(row_count + 1).replace(rw)
  #     row_count += 1       
  #   end
  #   book.write Rails.root.to_s + '/public/export/' + "弹幕_云词数据_#{td.strftime('%F')}.xls"  
  # end

  # 导出 我们15个 腾讯视频直播统计数据
  # def self.export_qqlive_statistics_data_excel(td,datas)
  #   book      = Spreadsheet::Workbook.new
  #   sheet1    = book.create_worksheet :name => '弹幕云词数据'
  #   row_count = 0
  #   sheet1.row(0).concat %w(姓名  关键词  频次)
  #   row_count = 0
  #   KWS.each do |name,arr|
  #     arr.each do |kwd|
  #       count = 0
  #       datas.each do |data|
  #         if data.cont.match(/#{kwd}/)
  #           count += 1
  #         end
  #       end
  #       rw = [name,kwd,count]
  #       sheet1.row(row_count + 1).replace(rw)
  #       row_count += 1
  #     end
  #   end
  #   book.write Rails.root.to_s + '/public/export/' + "弹幕_统计数据_#{td.strftime('%F')}.xls"  
  # end

end
