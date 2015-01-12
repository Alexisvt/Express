mocha.ui 'tdd'
assert = chai.assert

suite 'Global Test', ->
  test 'page has a valid title', ->
    assert(if document.title and document.title.match(/\S/) and document.title.toUpperCase() isnt 'TODO' then true else false)

mocha.run()
