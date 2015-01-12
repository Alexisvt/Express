mocha.ui 'tdd'
assert = chai.assert

suite  '"About" Page Tests', ->
  test 'page should contain link to contact page', ->
    assert($('a[href="/contact"]').length)

mocha.run()
