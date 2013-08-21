#= require json2
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require sqrt4/sqrt4
$ ->
  # Configure AJAX settings
  $.ajaxSetup({
    cache: false,
    timeout: 10000})


  # Where should this go?
  window.alertOverlay = (message, title, alertTarget, type = null) ->
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
    ov.addClass("alert-#{type || 'warning'}")

  window.processAjaxError = (title, xhr, show = false, alertTarget = null) ->
    alertOverlay(getErrorMessage(xhr), "Error #{title}", alertTarget, 'danger')

  window.getErrorMessage = (xhr) ->
    switch
      when xhr.responseText? && xhr.responseText.charAt(0) == '{' then $.parseJSON(xhr.responseText).message
      else
        "Server returned status code #{xhr.status}: #{xhr.statusText}"

  Sqrt4.Scheduler.add(new Sqrt4.ScheduledTask('overview', 2000, ->
    ov = $('#overview_inner')
    $.get('/overview.json', null,(data, status, xhr) ->
      ov.removeClass('text-danger')
      ov.html(data)
    ).fail((data) ->
      ov.addClass('text-danger')
      ov.html(getErrorMessage(data))
    )
  ))