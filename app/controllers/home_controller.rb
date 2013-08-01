class HomeController < ApplicationController
  def index
    @charts = [
        ['Past 24 hours', 30.minutes, 24.hours.ago],
        ['Past 7 days', 3.hours, 7.days.ago],
        ['Past month', 12.hours, 1.month.ago],
        ['Past year', 6.days, 1.year.ago]
    ]
  end

  def chart
    @start = DateTime.parse(params[:start])
    @interval = params[:interval].to_i
    @title = params[:title]
    render layout: false
  end
end