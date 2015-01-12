fortuneCookies = [
  "Conquer your fears or they will conquer you."
  "Rivers need springs."
  "Do not fear what you don't know."
  "You will have a pleasant surprise."
  "Whenever possible, keep it simple."
]

# If you want
# something to be visible outside of the module, you have to add it to  exports . In this
# example, the function  getFortune will be available from outside this module, but our
# array  fortuneCookies will be completely hidden
exports.getFortune = ->
  idx = Math.floor(Math.random() * fortuneCookies.length)
  fortuneCookies[idx]
