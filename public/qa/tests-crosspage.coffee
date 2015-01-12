Browser = require 'zombie'
assert = require('chai').assert
browser = undefined

suite 'Cross-Page Tests', ->

  setup ->
    browser = new Browser()
    return

  test 'requesting a group rate quote from the hood river tour page should populate the referrer field', (done)->
    referrer = 'http://localhost:3000/tours/hood-river'
    browser.visit referrer, ->
      browser.clickLink '.requestGroupRate', ->
        assert browser.field('referrer').value is referrer
        done()
        return
      return

  test 'requesting a group rate from the oregon coast tour page should populate the referrer field', (done)->
    referrer = 'http://localhost:3000/tours/oregon-coast'
    browser.visit referrer, ->
      browser.clickLink '.requestGroupRate', ->
        assert browser.field('referrer').value is referrer
        done()
        return
      return

  test 'visiting the "request group rate" page dirctly should result in an empty referrer field', (done) ->
    browser.visit 'http://localhost:3000/tours/request-group-rate', ->
      assert browser.field('referrer').value is ''
      done()
      return
    return
  return
