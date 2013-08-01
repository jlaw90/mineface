class HomeController < ApplicationController
  def index
    start24 = 24.hours.ago.getutc
    start24 = Time.at(start24.to_i - (start24.to_i % 3600))
    @charts = [
        ['Past 24 hours', 30.minutes, start24],
        ['Past 7 days', 3.hours, 7.days.ago.beginning_of_day.getutc],
        ['Past month', 12.hours, 1.month.ago.beginning_of_day.getutc],
        ['Past year', 6.days, 1.year.ago.beginning_of_day.getutc]
    ]
  end

  def chart
    @start = DateTime.parse(params[:start]).getutc
    @interval = params[:interval].to_i
    @title = params[:title]
    render json: {
        title: @title,
        start: @start.to_i*1000,
        data: get_data(@start, @interval)
    }
  end

  private

  def get_data(start, interval)
    # Select the data within range
    data = DataPoint.where(created_at: start...DateTime.now.getutc).sort_by(&:created_at)

    # Can just use them as seconds since epoch from here on out
    interval = interval.to_i
    start = start.to_i

    # Group the data by our interval
    grouped = data.group_by do |dp|
      utime = dp.created_at.to_i - start
      utime / interval
    end

    # Average and return as time, value pairs
    grouped.map do |idx, bucket|
      sum = bucket.map(&:value).reduce(:+)
      avg = sum / bucket.length
      time = (start + idx * interval) * 1000
      [time, avg]
    end
  end
end