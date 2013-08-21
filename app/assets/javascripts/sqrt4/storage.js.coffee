# Some basic methods around HTML5 storage
# Authored by James Lawrence
# Copyright 2013 Sqrt4, All Rights Reserved

supported = ->
  try
    return window.localStorage?
  catch e
    return false;

window.Storage.retrieve = (key, def = null) ->
  return def unless supported
  val = localStorage[key]
  return def if (typeof(val) == 'undefined')
  return null if val == null
  return JSON.parse(val)

window.Storage.store = (key, val) ->
  return unless supported
  localStorage[key] = JSON.stringify(val)