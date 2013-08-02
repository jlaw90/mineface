class HomeController < ApplicationController
  def index
    start24 = 24.hours.ago.getutc
    start24 = Time.at(start24.to_i - (start24.to_i % 3600))
    @charts = [
        ['Past 60 minutes', 5.minutes, 60.minutes.ago],
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

  def overview
    @devs = simplify(miner.devs, :devs)
    render json: {
        devices: @devs.nil? ? nil : @devs[:data].length,
        speed: @devs.nil? ? nil : mhash_to_s(@devs[:data].map { |dev| dev[:mhs_5s] }.reduce(:+))
    }
  end

  def devices
    # Get device json data
    @devs = simplify(miner.devs, :devs)
    render layout: false, partial: 'devices'
  end

  def pools
    @pools = simplify(miner.pools, :pools)
    render layout: false, partial: 'pools'
  end

  private
  def simplify(source, key)
    return nil if source[:status] == :error
    source[:data] = source[:data][key]
    source
  end

  def get_data(start, interval)
    # Select the data within range
    data = DataPoint.range(start, DateTime.now.getutc)

    # Can just use them as seconds since epoch from here on out
    interval = interval.to_i
    start = start.to_i

    # Group the data by our interval
    grouped = data.group_by do |dp|
      utime = dp[:time] - start
      utime / interval
    end

    # Average and return as time, value pairs
    grouped.map do |idx, bucket|
      sum = bucket.map { |d| d[:value] }.reduce(:+)
      avg = sum / bucket.length
      time = (start + idx * interval) * 1000
      [time, avg]
    end
  end
end