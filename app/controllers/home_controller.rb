class HomeController < ApplicationController
  include ActionView::Helpers::DateHelper

  def index
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

    interval = interval.to_f
    start = start.to_i

    groups = Array.new((endy.to_i - start) / interval.to_i) { [] }

    # Group the data by our interval
    data.each do |dp|
      utime = dp[:time] - start
      idx = (utime.to_f / interval).floor
      groups[idx-1] << dp[:value]
    end

    # Average and return as time, value pairs
    groups.map do |arr|
      arr.empty? ? 0 : arr.reduce(:+) / arr.length
    end
  end
end