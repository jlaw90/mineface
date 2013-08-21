#= require highcharts
#= require modules/exporting

# Todo: a fair bit of localisation to do here, still not 100% sure what would be the best method

$ ->
  # Schedule chart refreshing
  Sqrt4.Scheduler.add(new Sqrt4.ScheduledTask('chart', 5000, ->
    chartInterval = (intvalsel.val() * intunsel.val())
    chartRange = rangevalsel.val() * rangeunsel.val()
    ctask = Sqrt4.Scheduler.task('chart')
    chart.showLoading() if chartInterval != (ctask.interval / 1000) || chartRange != ctask.last_range
    ctask.last_range = chartRange

    start = (new Date().getTime() / 1000) - chartRange
    start -= start % chartInterval

    params = {
      start: start,
      interval: chartInterval
    }
    $.get('/chart.json', params,(data, status, xhr) ->
      ctask.interval = chartInterval * 1000 # Refresh in interval seconds
      if chart.series.length == 0
        chart.addSeries({}, false)
      series = chart.series[0]
      series.update({pointInterval: chartInterval * 1000, pointStart: start * 1000})
      series.setData(data.data)
      chart.hideLoading()
      # Chart isn't re-created on success, so we might need to hide the error alert...
      $('#chart_container .panel-content .alert-overlay').fadeOut()
    , 'json').fail (data) ->
      ctask.interval = 5000 # Try again in 5 seconds...
      processAjaxError('retrieving chart data', data, false, '#chart_container .panel-content')
  ))

  # Schedule device refreshing
  Sqrt4.Scheduler.add(new Sqrt4.ScheduledTask('devices', 5000, ->
    $.get('/devices.json', null,(data, status, xhr) ->
      $('#device_container').html($(data))
    ).fail (data) ->
      sel = '#device_container .panel-content'
      processAjaxError('retrieving device information', data, false, '#device_container .panel-content',
        '#device_container .panel-title')
  ))

  # Schedule pool refreshing
  Sqrt4.Scheduler.add(new Sqrt4.ScheduledTask('pools', 5000, ->
    $.get('/pools.json', null,(data, status, xhr) ->
      $('#pool_container').html($(data))
    ).fail (data) ->
      processAjaxError('retrieving pool information', data, false, '#pool_container .panel-content')
  ))

  # Load chart options
  opts = Storage.retrieve('chart.options', {range: {unit: 3600, value: 24}, interval: {unit: 60, value: 5}})
  rangevalsel.val(opts.range.value)
  rangeunsel.val(opts.range.unit)
  intvalsel.val(opts.interval.value)
  intunsel.val(opts.interval.unit)

  # Save chart options and refresh on interval or range change
  for sel in [rangevalsel, rangeunsel, intvalsel, intunsel]
    sel.change ->
      refreshChart(0, true)
      Storage.store('chart.options',
      { range: {unit: rangeunsel.val(), value: rangevalsel.val()}, interval: {unit: intunsel.val(), value: intvalsel.val()}})

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
    return Sqrt4.showMessage('Please enter a pool url') unless $('#pool_url').val()
    return Sqrt4.showMessage('Please enter a username') unless $('#pool_user').val()
    return Sqrt4.showMessage('Please enter a password') unless $('#pool_pass').val()
    params = {src: $('#pool_editmode').val(), url: $('#pool_url').val(), user: $('#pool_user').val(), pass: $('#pool_pass').val()}
    showWait(if params.src == 'new' then 'Creating pool' else 'Updating pool') # Todo: localise
    url = if params.src == 'new' then '/pool/create.json' else "/pool/#{params.src}/update.json"
    $.get(url, params, ((data, status, xhr) ->
      Sqrt4.Scheduler.execute('pools') # Refresh the pools Todo: mark save button with data-scheduler-exec
      hideWait()
    )).fail((data) ->
      processAjaxError("#{if params.src == 'new' then 'creat' else 'updat'}ing pool", data, true)
      hideWait())