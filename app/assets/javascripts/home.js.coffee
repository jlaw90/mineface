# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require highcharts
#= require modules/exporting

window._chartRefreshInterval = 30
window._chartRefreshTime = 0
window._deviceRefreshInterval = 5
window._poolRefreshInterval = 5

$ ->
  window.refreshChart = (time = 0, manual = false)->
    chartInterval = (intvalsel.val() * intunsel.val())
    dif = if time == 0 then 0 else (time - window._chartRefreshTime) % chartInterval
    return unless dif == 0 or manual
    window._chartRefreshTime = window.time
    chart.showLoading() if manual
    rv = rangevalsel.val()
    ru = rangeunsel.val()
    iv = intvalsel.val()
    iu = intunsel.val()
    params = {
      start: (new Date().getTime() / 1000) - (rv * ru),
      interval: iv * iu
    }
    $.get('/chart', params,(data, status, xhr) ->
      chart.setTitle("Past #{rv} #{ru}")

      if chart.series.length == 0
        chart.addSeries({}, false)
      series = chart.series[0]
      series.update({pointInterval: iv * iu * 1000, pointStart: new Date().getTime() - (rv * ru)})
      series.setData(data.data)
      chart.hideLoading()
    , 'json').fail (data) ->
      bootstrapAlert('chart_err', "#{data.status} #{data.statusText}", 'Failed to load chart data')

  window.refreshDevices = (time = 0) ->
    dif = time % window._deviceRefreshInterval
    return unless dif == 0
    $.get('/devices', null,(data, status, xhr) ->
      $('#device_container').html($(data))
    ).fail (data) ->
      bootstrapAlert('device_err', "#{data.status} #{data.statusText}", 'Failed to fetch device information')

  window.refreshPools = (time = 0) ->
    dif = time % window._poolRefreshInterval
    return unless dif == 0
    $.get('/pools', null,(data, status, xhr) ->
      $('#pool_container').html($(data))
    ).fail (data) ->
      bootstrapAlert('pool_err', "#{data.status} #{data.statusText}", 'Failed to fetch pool information')

  rangevalsel.change ->
    refreshChart(0, true)
    sset('hchart_range_value', rangevalsel.val())
  rangeunsel.change ->
    refreshChart(0, true)
    sset('hchart_range_unit', rangeunsel.val())

  intvalsel.change ->
    refreshChart(0, true)
    sset('hchart_interval_value', intvalsel.val())
  intunsel.change ->
    refreshChart(0, true)
    sset('hchart_interval_unit', intunsel.val())

  # Todo: work out what would be good defaults
  rangevalsel.val(sget('hchart_range_value', 24)) # 24
  rangeunsel.val(sget('hchart_range_unit', 3600)) # hours
  intvalsel.val(sget('hchart_interval_value', 5)) # 5
  intunsel.val(sget('hchart_interval_unit', 60)) # mins

  # Add refresh members
  addRefreshFunction(refreshChart)
  addRefreshFunction(refreshDevices)
  addRefreshFunction(refreshPools)