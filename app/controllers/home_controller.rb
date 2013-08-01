class HomeController < ApplicationController
  def index
    @charts = [
        ['Past 24 hours', 30.minutes, 24.hours.ago.getutc],
        ['Past 7 days', 3.hours, 7.days.ago.beginning_of_day.getutc],
        ['Past month', 12.hours, 1.month.ago.beginning_of_day.getutc],
        ['Past year', 6.days, 1.year.ago.beginning_of_day.getutc]
    ]
  end

  def chart
    @start = DateTime.parse(params[:start]).utc
    @interval = params[:interval].to_i
    @title = params[:title]
    render layout: false
  end
end