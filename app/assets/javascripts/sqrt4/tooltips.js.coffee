# Handle tooltip popups using data API, handle tooltips persisting accross ajax queries
# Authored by James Lawrence
# Copyright 2013 Sqrt4, All Rights Reserved

prevTooltipSource = null # For persisting tooltip after AJAX call replaces content (won't work in IE I don't think but oh well)
bindTooltip = (ele) ->
  return if ele.length == 0
  $.each(ele, ->
    ele = $(this)

    # Tooltip handler registration...
    return if ele.tooltip_registered? and ele.tooltip_registered
    unless ele.attr('id')
      console.error('Tooltip source without id attribute')
      return
    ele.tooltip_registered = true

    # Process options, set the correct container if a parent has a data-tooltip-container attribute
    container = ele.parents('*[data-tooltip-container]')
    opts = {delay: 0, trigger: 'hover focus', title: ele.data('tooltip')}
    opts.container = container unless container.length == 0

    ele.tooltip(opts) # Create the tooltip with bootstrap
    ele.on('show.bs.tooltip', ->
      prevTooltipSource = $(this).attr('id')) # Save the last visible tooltip
    ele.on('hide.bs.tooltip', ->
      prevTooltipSource = null if prevTooltipSource == $(this).attr('id')) # Unset on hide

    # If this is called from an ajax load and this tooltip was the last visible, display the updated version (looks nifty)
    if prevTooltipSource == ele.attr('id')
      tt = ele.data('bs.tooltip')
      p = tt.options.animation
      tt.options.animation = false
      tt.show()
      tt.options.animation = p
  )

$(document).on('DOMNodeInserted', (evt) ->
  bindTooltip($(evt.target).find('*[data-tooltip]'))) # Bind on ajax

$ ->
  bindTooltip($('*[data-tooltip]')) # Bind tooltip to existing elements on document load