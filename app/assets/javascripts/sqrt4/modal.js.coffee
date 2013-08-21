# Handles modals (popups, cofirmations, progress locks) and supports basic layering

# Pops up an informative message to the user
Sqrt4.showMessage = (message, title = null) ->
  $('#message-title').text(if title == null then ($('#message-title').data('default') || 'Message') else title)
  $('#message').text(message)
  $('#message-icon').attr('class', 'icon-info-sign')
  $('#message-cancel').hide()
  $('#message-modal').modal('show')

# Pops up a confirmation dialog, title and callback are optional
# callback should be of prototype (status) and status will be a boolean of true for confirmed and false otherwise
Sqrt4.showConfirmation = (message, callback, title = null) ->
  $('#message-title').text(if title == null then ($('#message-title').data('default') || 'Confirm') else title)
  $('#message').text(message)
  $('#message-icon').attr('class', 'icon-question-sign')
  $('#message-cancel').show()
  modal = $('#message-modal')
  modal.modal('show')
  okbut = $('#message-ok')
  cancelbut = $('#message-cancel')

  clicky = (ok) ->
    okbut.off('click', clicky)
    cancelbut.off('click', clicky)
    callback(ok)

  okbut.on 'click', ->
    clicky(true)
  cancelbut.on 'click', ->
    clicky(false)

# Show a progress bar in a modal that can't be closed (must hide manually on completion or the ui will be locked!)
Sqrt4.showWait = (msg) ->
  text = $('#progress_modal').find('#wait-message')
  text.text(msg)
  $('#progress_modal').modal({keyboard: false, backdrop: 'static'})

Sqrt4.hideWait = ->
  $('#progress_modal').modal('hide')

layers = []
layers.visible = null

# -- Layering support for bootstrap follows

# Add the new modal to the top of the stack
$(document).on('show.bs.modal', (evt) ->
  layers.push(layers.visible) if layers.visible? and !$(layers.visible).data('modal-top')? # Don't stack progress dialogs, confirmations etc.
  layers.visible = evt.target
)

# Show the previous modal when hiding (unless data-modal-top is set)
$(document).on('hide.bs.modal', (evt) ->
  e = evt.target
  if layers.visible == e # Top layer is hiding, show previous
    layers.visible = null
    prev = layers.pop()
    $(prev).modal('show') if prev?
)