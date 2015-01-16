express = require 'express'

###
We are adding our new module that we created before
Note that we prefix our module name with ./ the dot
This signals to Node that it should not
look for the module in the node_modules directory
###
fortune = require './lib/fortune.coffee'
formidable = require 'formidable'
bodyParser = require 'body-parser'
credentials = require './lib/credentials.coffee'

app= express()

###
We define the view folder and the view engine,
in this case JADE and the views folder
app.set 'views', __dirname + '/views'
###
app.set 'view engine', 'jade'

#We set the port
app.set 'port', process.env.PORT || 3000

# Enable template caching
app.set 'view cache', true

################### Middlewares Section  ###############
app.use bodyParser.json()

app.use bodyParser.urlencoded(extended : true)

app.use (req,res,next) ->
  if app.get('env') isnt 'production' and req.query.test is '1'
    res.locals.showTests = true
  else
    res.locals.showTests = false
  next()
  return
###
Esta es otra manera de hacerlo
res.locals.showTests = if app.get('env') isnt 'production'
and req.query.test is '1' then true else false
###

################### routing to / page  #################

# Routing for uploading images
app.get '/contest/vacation-photo', (req,res) ->
  now = new Date()
  res.render 'contest/vacation-photo',
    year: now.getFullYear()
    month: now.getMonth()
  return

app.post '/contest/vacation-photo/:year/:month', (req,res) ->
  form = new formidable.IncomingForm()
  form.parse req, (err,fields,files) ->
    return res.redirect 303, '/error' if err
    console.log 'received fields:'
    console.log fields
    console.log 'received files:'
    console.log files
    res.redirect 303,'/thank-you'
    return
  return

app.get '/thank-you', (req,res) ->
  res.render 'thank-you'
  return

app.get '/newsletter',(req,res) ->
  res.render 'newsletter',{csrf : 'CSRF token goes here'}
  return

app.get '/newsletterAjax',(req,res)->
  res.render 'newsletterAjax',{csrf : 'CSRF token goes here'}
  return

app.post '/process', (req,res)->
  console.log "Form (from querystring): #{req.query.form}"
  console.log "CSRF token (from hidden form field): #{req.body._csrf}"
  console.log "Name (from visible form field): #{req.body.name}"
  console.log "Email (from visible form field): #{req.body.email}"
  res.redirect 303,"/thank-you"
  return

app.post '/processAjax', (req, res) ->
  if req.xhr or req.accepts('json,html') is 'json'
    # If there were an error, we would send { error : 'error description'}
    res.send success: true
  else
    # If there were an error, we would redirect to an error page
    res.redirect 303, '/thank-you'
  return

app.get '/',(req, res)->
  res.render 'home'

#routing to about page
app.get '/about',(req, res)->
  res.render 'about', {fortune : fortune.getFortune()}
  return

# Route that show the header information from the browser and client
app.get '/headers', (req, res) ->
  res.set 'Content-Type', 'text/plain'
  s = ''
  for key, value of req.headers
    s += "#{key}: #{value}" + '\n'
  res.send s
  return

# TODO - We need to add the test views and configuring the routes
# the use of 'use' is for creating the middlewares

###
The static middleware allows you to designate one or
more directories as containing
static resources that are simply to be delivered to
the client without any special handling
###
app.use express.static(__dirname + "/public")

# custom 404 page
app.use (req, res)->
  res.type 'text/plain'
  res.status 404
  res.send '404 - Not Found'
  return

# custom 500 page
app.use (err,req,res,next)->
  console.log err.stack
  res.type 'text/plain'
  res.status 500
  res.send '500 - Server Error'
  return

app.listen(app.get('port'), ->
  console.log "Express started on http://localhost:#{app.get('port')}
  ; press Ctrl-C to terminate."
  return)
