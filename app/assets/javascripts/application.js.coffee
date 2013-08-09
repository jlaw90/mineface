#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap

window._refreshMap = {}
window.startTime = new Date().getTime()
window._alerts = {}

default_refresh = 5

window.addRefreshFunction = (name, funcy, interval = default_refresh) ->
  funcy.refresh_interval = interval
  funcy.refresh_pause = false
  window._refreshMap[name] = funcy

window.removeRefreshFunction = (name) ->
  delete window._refreshMap[name]

window.changeRefreshInterval = (name, interval) ->
  func = window._refreshMap[name]
  return unless func?
  func.refresh_interval = interval

window.setRefreshPaused = (name, paused = true) ->
  func = window._refreshMap[name]
  return unless func?
  func.refresh_pause = paused

window.doRefresh = (name) ->
  func = window._refreshMap[name]
  return unless func?
  func.refresh_last = window.time
  func()

window.refresh = () ->
  window.time = Math.round((new Date().getTime() - window.startTime) / 1000)
  $.each(window._refreshMap, (name, func) ->
    return if func.refresh_pause == true
    last = func.refresh_last || 0
    delta = window.time - last
    mod = delta % func.refresh_interval
    if mod == 0
      doRefresh(name)
  )
  setTimeout(refresh, 1000)

supports_html5_storage = ->
  try
    return window.localStorage?
  catch e
    return false;

window.sget = (key, def) ->
  return def unless supports_html5_storage()
  val = localStorage[key]
  if (val != null && typeof(val) != 'undefined')
    return val if def == null
    switch typeof(def)
      when 'string' then return val
      when 'number'
        return parseInt(val) if def == (def | 0)
        return parseFloat(val)
      when 'boolean' then return !!(val == 'true')
      else
        throw 'unknown storage type'
  return def

window.sset = (key, val) ->
  return unless supports_html5_storage()
  localStorage[key] = val

window.popup = (message, title = null) ->
  $('#message-title').text(if title == null then 'Message' else title)
  $('#message').text(message)
  $('#message-icon').attr('class', 'icon-info-sign')
  $('#message-cancel').hide()
  $('#message-modal').modal('show')

window.modalConfirm = (message, title = null) ->
  $('#message-title').text(if title == null then 'Confirm' else title)
  $('#message').text(message)
  $('#message-icon').attr('class', 'icon-question-sign')
  $('#message-cancel').show()
  modal = $('#message-modal')
  modal.removeAttr('data-result')
  modal.modal('show')

window.alertOverlay = (message, title, type, alertTarget) ->
  target = $(alertTarget)
  ov = target.children('.alert-overlay')
  if ov.length == 0
    ov = $('<div></div>')
    ov.css({'position': 'absolute', 'left': '0px', 'top': '0px', 'width': '100%', 'height': '100%', 'z-index': '999'})
    ov.hide()
    target.append(ov)
  ov.fadeIn()
  ov.empty()

  if title
    head = $('<h4></h4>')
    head.text(title)
    ov.append(head)

  content = $('<p></p>')
  content.text(message)
  ov.append(content)

  ov.attr('class', (i, c) ->
    (c || '').replace(/\balert-\S+/g, '') # Remove previous alert classes
  )
  ov.addClass('alert-overlay')
  ov.addClass('alert')
  ov.addClass("alert-#{type}") if type?


window.userAlert = (id, message, title, show = false, type = null, alertTarget = null) ->
  return if window._alerts[id]?
  if show
    return bootstrapAlert(id, message, title, type) # Show, don't push
  if alertTarget
    return alertOverlay(message, title, type, alertTarget)

window.bootstrapAlert = (id, message, title, type = null) ->
  modal = $('#alert_modal')
  content = modal.children('.modal-content')
  content.attr('class', (i, c) ->
    c.replace(/\balert-\S+/g, '') # Remove previous alert classes
  )
  content.addClass("alert-#{type}") if type?
  $('#alert-title').text(title)
  $('#alert_container').text(message)
  modal.modal('show')

window.processAjaxError = (title, xhr, show = false, alertTarget = null) ->
  userAlert(title, getErrorMessage(xhr), "Error #{title}", show, 'severe', alertTarget)

window.getErrorMessage = (xhr) ->
  message = "Server returned status code #{xhr.status}: #{xhr.statusText}"
  if xhr.responseText? && xhr.responseText != '' && xhr.responseText.charAt(0) == '{'
    message = $.parseJSON(xhr.responseText).message
  message

window.updateOverview = ->
  ov = $('#overview')
  $.get('/overview', null,(data, status, xhr) ->
    ov.removeClass('text-danger')
    ov.html(data)
  ).fail((data) ->
    ov.addClass('text-danger')
    ov.html(getErrorMessage(data))
  )

window.showWait = (msg) ->
  text = $('#progress_modal').find('#wait-message')
  text.text(msg)
  $('#progress_modal').modal({keyboard: false, backdrop: 'static'})

window.hideWait = ->
  $('#progress_modal').modal('hide')

$.rails.allowAction = (link) ->
  return true if link.data('confirmed') or !link.data('confirm')

  modalConfirm(link.data('confirm'), 'Delete confirmation')
  refresh = link.data('refresh')
  if refresh?
    setRefreshPaused(refresh, true)

  okbut = $('#message-ok')
  cancelbut = $('#message-cancel')

  okbut.on 'click', ->
    link.attr('data-confirmed', 'true')
    if refresh?
      setRefreshPaused(refresh, false)
    link.trigger('click')
    okbut.off('click')
    cancelbut.off('click')


  cancelbut.on 'click', ->
    if refresh?
      setRefreshPaused(refresh, false)
    okbut.off('click')
    cancelbut.off('click')

  false


addRefreshFunction('overview', window.updateOverview)
$ ->
  # Configure AJAX settings
  $.ajaxSetup({
    cache: false,
    timeout: 10000})
  # Start our refresh function
  setTimeout(refresh, 0);

  # Show the alert data after clicking...
  $('body').on('click', '*[data-alertid]', (evt) ->
    id = $(this).data('alertid')
    if($(this).data('dismiss') != 'alert')
      showAlert(id)
    removeAlert(id)
  )

  # Show the previous modal after a message modal if one existed (simple layering)
  $('#message-modal').on('hide.bs.modal', ->
    return unless window.prev_modal?
    mod = prev_modal
    delete window.prev_modal
    mod.modal('show')
  )

  # Show progress on ajax link click
  $('body').on 'ajax:beforeSend', (evt) ->
    e = $(evt.target)
    ref = e.data('refresh')
    if ref
      if e.data('remote')
        setRefreshPaused(ref, true)
      else
        doRefresh(ref)
    if e.data('perform')
      window._lastAjax = evt.target
      showWait(e.data('perform'))
    e.one('ajax:complete', (evt, xhr, status) ->
      e = $(evt.target)
      if e.data('perform') && window._lastAjax == evt.target
        hideWait()
      ref = e.data('refresh')
      if ref
        setRefreshPaused(ref, false)
        doRefresh(ref)
      unless xhr.status == 200
        msg = $(evt.target).data('perform') || 'performing ajax action'
        msg = msg.toLowerCase()
        processAjaxError(msg, xhr, true)
    )
    true
