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
          stm = item["监测日期开始日期"].match(/(\d+)月(\d+)日(\d{4})年/)
          etm = item["监测结束日期"].match(/(\d+)月(\d+)日(\d{4})年/)
          TiebaTheme.generate_reports(item["监测节目"], "#{stm[3]}-#{stm[1]}-#{stm[2]}", "#{etm[3]}-#{etm[1]}-#{etm[2]}")
        rescue Exception => e
          binding.pry
        end
      end
    end
  end
end

load_task_csv