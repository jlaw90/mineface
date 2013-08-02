#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap

window._refreshFuncs = []
window.startTime = new Date().getTime()

overview_refresh = 5

window.addRefreshFunction = (funcy) ->
  _refreshFuncs.push(funcy)

window.removeRefreshFunction = (funcy) ->
  idx = _refreshFuncs.indexOf(funcy)
  return if (idx == -1)
  _refreshFuncs.splice(idx, 1)

window.refresh = () ->
  window.time = Math.floor((new Date().getTime() - startTime) / 1000)
  for i in [0..._refreshFuncs.length]
    _refreshFuncs[i](window.time)
  setTimeout(refresh, 1000)

supports_html5_storage = ->
  try
    return 'localStorage' in window && window['localStorage'] != null;
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

window.bootstrapAlert = (id, message, title = null, type = null, block = false) ->
  $("\##{id}").remove()
  container = $('#alert_container')
  alert = $('<div></div>')
  alert.attr('id', id)
  alert.addClass('alert')
  alert.addClass("alert-#{type}") if type?
  alert.addClass("alert-block") if block?

  close = $('<button></button>')
  close.addClass('close')
  close.attr('data-dismiss', 'alert')
  close.html('&times;')
  alert.append(close)

  header = null
  if title != null
    header = $('<h4></h4>')
    header.text(title)
    alert.append(header)
  alert.append(message)
  alert.hide()
  container.append(alert)
  alert.fadeIn()


window.updateOverview = (time = 0) ->
  return unless time % overview_refresh == 0
  $('#overview').load('/overview')


addRefreshFunction(window.updateOverview)
$ ->
  setTimeout(refresh, 0);