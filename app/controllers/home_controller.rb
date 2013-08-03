class HomeController < ApplicationController
  include ActionView::Helpers::DateHelper

  def index
    start24 = 24.hours.ago.getutc
    start24 = Time.at(start24.to_i - (start24.to_i % 3600))
    start60min = 60.minutes.ago
    start60min = Time.at(start60min.to_i - (start60min.to_i % 300)) # Closest 5 minutes
    @charts = [
        ['Past 60 minutes (5 min avg)', 5.minutes, start60min],
        ['Past 24 hours (30 min avg)', 30.minutes, start24],
        ['Past 7 days (3 hour avg)', 3.hours, 7.days.ago.beginning_of_day.getutc],
        ['Past month (12 hour avg)', 12.hours, 1.month.ago.beginning_of_day.getutc],
        ['Past year (6 day avg)', 6.days, 1.year.ago.beginning_of_day.getutc]
    ]
  end

  def chart
    @start = Time.at(params[:start].to_i).to_datetime.getutc
    @interval = params[:interval].to_i
    @title = params[:title]
    render json: {
        title: @title,
        start: @start.to_i*1000,
        data: get_data(@start, @interval)
    }
  end

  def overview
    @devs = miner.devices
    unless @devs.empty?
      @sum = miner.summary
      @speed = mhash_to_s(@devs.map { |dev| dev[:mhs_5s] }.reduce(:+))
    end
    render layout: false
  end

  def devices
    # Get device json data
    miner.devices
    @devs = miner.devices
    render layout: false, partial: 'devices'
  end

  def pools
    @pools = miner.pools
    miner.summary
    render layout: false, partial: 'pools'
  end

  private
  def get_data(start, interval)
    # Select the data within range
    endy = DateTime.now.getutc
    data = DataPoint.range(start, endy)

    # Can just use them as seconds since epoch from here on out
    interval = interval.to_i
    start = start.to_i
    endy = endy.to_i

    grouped = Array.new((endy - start) / interval) { [] }

    # Group the data by our interval
    data.each do |dp|
      utime = dp[:time] - start
      idx = utime / interval
      grouped[idx - 1] << dp[:value]
    end

    # Average and return as time, value pairs
    grouped.map do |arr|
      arr.empty? ? 0 : arr.reduce(:+) / arr.length
    end
  end
end