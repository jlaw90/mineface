# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require highcharts
#= require modules/exporting

$ ->
  refreshChart = ->
    # Todo: use the API to load more data instead of reloading the element
    carea = $('.chart_area')
    # Apply to descendant if there...
    desc = carea.children('div')
    if(desc.length == 0)
      carea.loading()
    else
      desc.loading()
    $.get('/chart', charts[chart.val()], (data, status, xhr) ->
      carea.html(data))
    .fail (data, status, xhr) ->
        carea.html('<p>Failed to load graph for this time period</p>')

  chart.change ->
    refreshChart()
    sset('selected_chart', chart.val())

  addRefreshFunction(refreshChart)

  chart.val(sget('selected_chart', 0))