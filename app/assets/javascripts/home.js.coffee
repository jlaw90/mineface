# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require highcharts
#= require modules/exporting

_chartRefreshInterval = 30

$ ->
  window.refreshChart = (time = 0)->
    dif = time % _chartRefreshInterval
    $('#chart_refresh').text("refresh (" + (_chartRefreshInterval - dif) + "s)")
    return unless dif == 0
    # Todo: use the API to load more data instead of reloading the element
    carea = $('.chart_area')
    # Apply to descendant if there...
    chart.showLoading()
    chartdata = charts[chartsel.val()]
    $.get('/chart', chartdata,(data, status, xhr) ->
      chart.setTitle({text: data.title })
      chart.xAxis[0].setExtremes(data.start, new Date().getTime(), false)

      if chart.series.length == 0
        chart.addSeries({}, false)
      chart.series[0].setData(data.data)
      chart.hideLoading()
    ).fail (data) ->
      bootstrapAlert('chart_err', "#{data.status} #{data.statusText}", 'Failed to load chart data')

  chartsel.change ->
    refreshChart()
    sset('selected_chart', chartsel.val())

  addRefreshFunction(refreshChart)

  chartsel.val(sget('selected_chart', 0))