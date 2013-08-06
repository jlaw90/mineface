# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require highcharts
#= require modules/exporting

$ ->
  window.refreshChart = ->
    chartInterval = (intvalsel.val() * intunsel.val())
    chartRange = rangevalsel.val() * rangeunsel.val()
    window._chartRefreshTime = window.time
    chart.showLoading() if chartInterval != refreshChart.refresh_interval || chartRange != refreshChart.last_range
    refreshChart.refresh_interval = chartInterval
    refreshChart.last_range = chartRange

    start = (new Date().getTime() / 1000) - chartRange
    start -= start % chartInterval

    params = {
      start: start,
      interval: chartInterval
    }
    $.get('/chart', params,(data, status, xhr) ->
      if chart.series.length == 0
        chart.addSeries({}, false)
      series = chart.series[0]
      series.update({pointInterval: chartInterval * 1000, pointStart: start * 1000})
      series.setData(data.data)
      chart.hideLoading()
    , 'json').fail (data) ->
      processAjaxError('retrieving chart data', data)

  window.refreshDevices = ->
    $.get('/devices', null,(data, status, xhr) ->
      $('#device_container').html($(data))
    ).fail (data) ->
      processAjaxError('retrieving device information', data)

  window.refreshPools = ->
    $.get('/pools', null,(data, status, xhr) ->
      $('#pool_container').html($(data))
    ).fail (data) ->
      processAjaxError('retrieving pool information', data)

  # Load last selected chart
  rangevalsel.val(sget('hchart_range_value', 24)) # 24
  rangeunsel.val(sget('hchart_range_unit', 3600)) # hours
  intvalsel.val(sget('hchart_interval_value', 5)) # 5
  intunsel.val(sget('hchart_interval_unit', 60)) # mins

  changeHandle = (src, key) ->
    refreshChart(0, true)
    sset("hchart_#{key}", $(src).val())

  # Add selection changes
  rangevalsel.change ->
    changeHandle(this, 'range_value')
  rangeunsel.change ->
    changeHandle(this, 'range_unit')
  intvalsel.change ->
    changeHandle(this, 'interval_value')
  intunsel.change ->
    changeHandle(this, 'interval_unit')

  # Add refresh functions
  addRefreshFunction('chart', refreshChart)
  addRefreshFunction('devs', refreshDevices)
  addRefreshFunction('pools', refreshPools)

  # New pool
  $('body').on('click', '#new_pool', (evt) ->
    # Called when new pool button is clicked
    $('#pool_url').val('');
    $('#pool_user').val('');
    $('#pool_pass').val('');
    $('#pool_editmode').val('new')
  )

  # Edit pool
  $('body').on('click', '*[data-pooledit]', (evt) ->
    id = $(this).data('pooledit')
    url = $("#pool#{id}_url")
    user = $("#pool#{id}_user")
    $('#pool_url').val(url.text());
    $('#pool_user').val(user.text());
    $('#pool_pass').val('');
    $('#pool_editmode').val(id)
    $('#pool_settings').modal('show')
  )

  # Save changes
  $('#save_pool').click ->
    window.prev_modal = $('#pool_settings')
    return popup('Please enter a pool url') unless $('#pool_url').val()
    return popup('Please enter a username') unless $('#pool_user').val()
    return popup('Please enter a password') unless $('#pool_pass').val()
    window.prev_modal = null
    params = {src: $('#pool_editmode').val(), url: $('#pool_url').val(), user: $('#pool_user').val(), pass: $('#pool_pass').val()}
    showWait(if params.src == 'new' then 'Creating pool' else 'Updating pool')
    url = if params.src == 'new' then '/pool/create' else "/pool/#{params.src}/update"
    $.get(url, params, ((data, status, xhr) ->
      refreshPools(0)
      hideWait()
    )).fail((data) ->
      processAjaxError("#{if params.src == 'new' then 'creat' else 'updat'}ing pool", data, true)
      hideWait())
