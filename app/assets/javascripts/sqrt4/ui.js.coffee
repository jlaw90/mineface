# Add some nice overrides for rails and jquery events using our lib
# Authored by James Lawrence
# Copyright 2013 Sqrt4, All Rights Reserved

# Override rail.allowAction to show a bootstrap modal instead of the native confirm dialog
$.rails.allowAction = (link) ->
  if link.data('confirmed') or !link.data('confirm')
    link.removeAttr('data-confirmed')
    return true

  # If the link causes a scheduled task to be executed, pause that task until confirmation closes
  refresh = link.data('scheduler-exec')
  if refresh?
    Sqrt4.Scheduler.pause(refresh)
    # To avoid a race condition if a refresh already removed this element before we paused
    unless $.contains(document.documentElement, link[0])
      $("##{link.attr('id')}").click()
      return false

  Sqrt4.showConfirmation(link.data('confirm'), (result) ->
    link.attr('data-confirmed', 'true') if result
    Sqrt4.Scheduler.pause(refresh, false) if refresh? # Re-enable refreshing
    link.click() if result #Re-click
  )
  false # Return false, the re-triggered click on confirmation will return true and magic will happen :)


# This method handles multiple things
# It handles data-scheduler-exec processing
$(document).on 'ajax:beforeSend', (evt) ->
  e = $(evt.target)
  ref = e.data('scheduler-exec')
  if ref
    if e.data('remote') # We need to wait until we get the results...
      Sqrt4.Scheduler.pause(ref, true)
      # Protect race condition where a refresh happened and the element no longer exists
      unless $.contains(document.documentElement, e[0])
        id = e.attr('id')
        console.error('Reclick not handled for multiple elements in beforeSend') if e.length != 1
        console.error('No id!') unless id?
        ne = $("##{id}")
        ne.data('confirmed', e.data('confirmed')) if e.data('confirmed') # Make sure it has the same modal confirmation
        ne.trigger('click')
        return false
    else
      Sqrt4.Scheduler.execute(ref)
  if e.data('perform') # Show an uncloseable modal overlay
    _lastAjax = evt.target
    Sqrt4.showWait(e.data('perform'))

  # Add a one-shot handler for completion
  e.one('ajax:complete', (evt, xhr, status) ->
    e = $(evt.target)
    if e.data('perform') && _lastAjax == evt.target
      Sqrt4.hideWait()
    ref = e.data('scheduler-exec')
    if ref
      Sqrt4.Scheduler.pause(ref, false)
      Sqrt4.Scheduler.execute(ref)
    unless xhr.status == 200
      msg = $(evt.target).data('perform') || 'performing ajax action'
      msg = msg.toLowerCase()
    # Todo: I removed the alert modal because I didn't think it was used anymore... d'oh
    # processAjaxError(msg, xhr)
  )
  true