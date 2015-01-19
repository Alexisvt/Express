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

app.use require('cookie-parser')(credentials.cookieSecret)

app.use require('express-session')()

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

# if there's a flash message, transfer
# it to the context, then clear it
app.use (req,res,next) ->
  res.locals.flash = req.session.flash
  delete req.session.flash
  next()
  return
################### routing to / page  #################

app.post '/newsletterSession', (req,res) ->
  name = req.body.name || ''
  email = req.body.email || ''

  # Email validation
  unless email.match(VALID_EMAIL_REGEX)
    return res.json error : 'Invalid name email address.' if req.xhr
    req.session.flash =
      type : 'danger'
      intro : 'Validation error!'
      message : 'The email addres '
    return res.redirect 303, '/archive'

  new NewsletterSignup( name: name, email: email ).save (err)->
    if err
      return res.json error: 'Databases error.' if req.xhr
      req.session.flash =
        type: 'danger'
        intro: 'Databases error!'
        message: 'There was a databases error; please try again later'
      return res.redirect 303, '/archive'

    return res.json success : true if req.xhr
    req.session.flash =
      type : 'success'
      intro : 'Thank you'
      message : 'You have now been sign up for the newsletter.'
    return res.redirect 303, '/archive'

app.get '/newsletterSession', (req,res) ->
  res.render 'newsletterSession'
  return

# Cookie routing
app.get '/cookie-test', (req,res) ->
  monsterCookieValue = ''

  #verifie if the cookie exist if not create it
  unless req.cookies.monster
    res.cookie 'monster', 'hola mundo'
  else
    monsterCookieValue = req.cookies.monster

  res.render 'cookie-test', {monster : monsterCookieValue}
  return

#res.cookie 'signed_monster', 'signed_monster data', signed : true

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

app.get '/archive', (req,res) ->
  res.reder 'archive'
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

app.listen app.get('port'), ->
  console.log "Express started on http://localhost:#{app.get('port')}
  ; press Ctrl-C to terminate."
  return
