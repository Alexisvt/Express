express = require 'express'

# We are adding our new module that we created before
# Note that we prefix our module name with  ./ . This signals to Node that it should not
# look for the module in the node_modules directory
fortune = require './lib/fortune.coffee'

app= express()

#We define the view folder and the view engine, in this case JADE and the views folder
#app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

#We set the port
app.set 'port', process.env.PORT || 3000

app.use (req,res,next) ->
  res.locals.showTests = if app.get('env') isnt 'production' and req.query.test is '1' then true else false
  next()
  return

#routing to / page
app.get '/',(req, res)->
  res.render 'home'

#routing to about page
app.get '/about',(req, res)->
  res.render 'about', {fortune : fortune.getFortune()}
  return

# the use of 'use' is for creating the middlewares

#The  static middleware allows you to designate one or more directories as containing
#static resources that are simply to be delivered to the client without any special handling
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
  console.log 'Express started on http://localhost:' + app.get('port') + '; press Ctrl-C to terminate.'
  return)
