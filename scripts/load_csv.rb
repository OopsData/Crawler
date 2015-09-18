require File.expand_path('../../config/application', __FILE__)
require File.expand_path('../../app/models/tieba_theme', __FILE__)
Rails.application.load_tasks

require 'csv'

def load_task_csv
  binding.pry
  ARGV.each do |file|
    p file
    CSV.open(file, "r", :headers => true) do |csv|
      while item = csv.readline
        begin
          break if item.blank?
          item["监测节目"]
          binding.pry
          st = Time.parse(item["监测日期开始日期"].gsub(/[日年]/, ' ').sub('月', '-'))
          et = Time.parse(item["监测结束日期"].gsub(/[日年]/, ' ').sub('月', '-'))
          TiebaTheme.generate_reports(item["监测节目"], st.strftime("%F"), et.strftime("%F"))
        rescue Exception => e
          binding.pry
        end
      end
    end
  end
end

load_task_csv