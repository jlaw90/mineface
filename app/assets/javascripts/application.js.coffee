#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap

window._refreshFuncs = []
window._refreshMap = {}
window.startTime = new Date().getTime()
window._alerts = []

default_refresh = 500

window.addRefreshFunction = (name, funcy, interval = default_refresh) ->
  funcy.refresh_interval = interval
  funcy.refresh_pause = false
  _refreshFuncs.push(funcy)
  window._refreshMap[name] = funcy

window.removeRefreshFunction = (name) ->
  window._refreshMap[name] = null
  idx = _refreshFuncs.indexOf(funcy)
  return if (idx == -1)
  _refreshFuncs.splice(idx, 1)

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
  for i in [0..._refreshFuncs.length]
    func = _refreshFuncs[i]
    continue if func.refresh_pause == true
    last = func.refresh_last || 0
    delta = window.time - last
    mod = delta % func.refresh_interval
    if mod == 0
      func.refresh_last = window.time
      func()
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
  modal.attr('data-result', '')
  modal.modal('show')

window.userAlert = (id, message, title, show = false, type = null) ->
  return if $("\#show_alert#{id}").length > 0
  if show
    return bootstrapAlert(id, message, title, type) # Show, don't push
  alert = {id: id, message: message, title: title, type: type}
  idx = window._alerts.push(alert) - 1
  $('#no_alerts').hide()
  $('#alert_count').text(window._alerts.length.toString())
  li = $('<li></li>')
  link = $('<a></a>')
  link.addClass('menuitem')
  link.attr('id', "show_alert#{idx}")
  link.attr('href', '#')
  link.attr('onclick', 'return false')
  link.text(title)
  li.append(link)
  ul = $('#alert-dropdown')
  ul.append(li)
  link.attr('data-alertidx', "#{idx}")


window.bootstrapAlert = (id, message, title, type = null) ->
  $("\##{id}").remove()
  modal = $('#alert_modal')
  content = modal.children('.modal-content')
  content.attr('class', (i, c) ->
    c.replace(/\balert-\S+/g, '') # Remove previous alert classes
  )
  content.addClass("alert-#{type}") if type?
  $('#alert-title').text(title)
  $('#alert_container').text(message)
  modal.modal('show')

window.removeAlert = (id) ->
  $("\##{id}").fadeOut()

window.processAjaxError = (title, xhr, show = false) ->
  message = "Server returned status code #{xhr.status}: #{xhr.statusText}"
  if xhr.responseText? && xhr.responseText != ''
    message = JSON.parse(xhr.responseText).message
  userAlert(title, message, "Error while #{title}", show)

window.updateOverview = ->
  $('#overview').load('/overview')

window.showWait = (msg) ->
  text = $('#progress_modal').find('#wait-message')
  text.text(msg)
  $('#progress_modal').modal({keyboard: false, backdrop: 'static'})

window.hideWait = ->
  $('#progress_modal').modal('hide')

window.showAlert = (idx) ->
  alert = window._alerts[idx]
  bootstrapAlert(alert.id, alert.message, alert.title, alert.type || null)

window.removeAlert = (idx) ->
  window._alerts.splice(idx, 1)
  $("#show_alert#{idx}").remove()
  if window._alerts.length == 0
    $('#no_alerts').show()
    $('#alert_count').text('')
  else
    $('#alert_count').text(window._alerts.length.toString())

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
  $.ajaxSetup({
    cache: false,
    timeout: 10000})
  setTimeout(refresh, 0);
  $('body').on('click', '*[data-alertidx]', (evt) ->
    idx = $(this).data('alertidx')
    showAlert(idx)
    removeAlert(idx)
  )
  $('#message-modal').on('hide.bs.modal', ->
    return unless window.prev_modal?
    mod = prev_modal
    window.prev_modal = null
    mod.modal('show')
  )
  $('body').on('click', '*[data-refresh]', (evt) ->
    return if $(this).data('remote') # Handle confirm callback instead
    name = $(this).data('refresh')
    return unless name
    doRefresh(name)
  )
  $('body').on 'ajax:complete', '*[data-refresh]', (evt, xhr, status) ->
    name = $(this).data('refresh')
    return unless name
    doRefresh(name)