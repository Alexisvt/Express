app = require('express')()

# Middleware examples
app.use (req,res,next) ->
  console.log '\n\nALLWAYS'
  next()

app.get '/a', (req,res) ->
  console.log '/a: route terminated'
  res.send('a')

app.get '/a', (req,res) ->
  console.log '/a: never called'

app.get '/b', (req,res,next) ->
  console.log '/b: route not terminated'
  next()

app.use (req,res,next) ->
  console.log 'SOMETIMES'
  next()

app.get '/b', (req,res,next) ->
  console.log '/b (part 2): error thrown'
  throw new Error 'b failed'

# Error Middleware
app.use '/b', (err,req,res,next) ->
  console.log '/b Error detected and passed on'
  next(err)

app.get '/c', (err,req) ->
  console.log '/c: error thrown'
  throw new Error 'c failed'

app.use '/c', (err,req,res,next) ->
  console.log '/c: error detected but not passed on'
  next()

app.use (err,req,res,next) ->
  console.log "unhandled error detected: #{err.message}"
  res.status 500
  res.send '500 - server error'

app.use (req,res) ->
  console.log 'router not handled'
  res.status 404
  res.send('404 - not found')

app.listen 3000, ->
  console.log 'listening on 3000'
