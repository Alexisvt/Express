var app, bodyParser, credentials, express, formidable, fortune;

express = require('express');


/*
We are adding our new module that we created before
Note that we prefix our module name with ./ the dot
This signals to Node that it should not
look for the module in the node_modules directory
 */

fortune = require('./lib/fortune.coffee');

formidable = require('formidable');

bodyParser = require('body-parser');

credentials = require('./lib/credentials.coffee');

app = express();


/*
We define the view folder and the view engine,
in this case JADE and the views folder
app.set 'views', __dirname + '/views'
 */

app.set('view engine', 'jade');

app.set('port', process.env.PORT || 3000);

app.set('view cache', true);

app.use(require('cookie-parser')(credentials.cookieSecret));

app.use(require('express-session')({
  secret: credentials.cookieSecret,
  resave: true,
  saveUninitialized: true
}));

app.use(bodyParser.json());

app.use(bodyParser.urlencoded({
  extended: true
}));

app.use(function(req, res, next) {
  if (app.get('env') !== 'production' && req.query.test === '1') {
    res.locals.showTests = true;
  } else {
    res.locals.showTests = false;
  }
  next();
});


/*
Esta es otra manera de hacerlo
res.locals.showTests = if app.get('env') isnt 'production'
and req.query.test is '1' then true else false
 */

app.use(function(req, res, next) {
  res.locals.flash = req.session.flash;
  delete req.session.flash;
  next();
});

app.post('/newsletterSession', function(req, res) {
  var email, name;
  name = req.body.name || '';
  email = req.body.email || '';
  if (!email.match(/\S+@\S+\.\S+/)) {
    if (req.xhr) {
      return res.json({
        error: 'Invalid name email address.'
      });
    }
    req.session.flash = {
      type: 'danger',
      intro: 'Validation error!',
      message: 'The email addres '
    };
    return res.redirect(303, '/archive');
  }
  new NewsletterSignup({
    name: name,
    email: email
  }).save(function(err) {
    if (err) {
      if (req.xhr) {
        return res.json({
          error: 'Databases error.'
        });
      }
      req.session.flash = {
        type: 'danger',
        intro: 'Databases error!',
        message: 'There was a databases error; please try again later'
      };
      return res.redirect(303, '/archive');
    }
    if (req.xhr) {
      return res.json({
        success: true
      });
    }
    req.session.flash = {
      type: 'success',
      intro: 'Thank you',
      message: 'You have now been sign up for the newsletter.'
    };
    return res.redirect(303, '/archive');
  });
});

app.get('/newsletterSession', function(req, res) {
  res.render('newsletterSession');
});

app.get('/cookie-test', function(req, res) {
  var monsterCookieValue;
  monsterCookieValue = '';
  if (!req.cookies.monster) {
    res.cookie('monster', 'hola mundo');
  } else {
    monsterCookieValue = req.cookies.monster;
  }
  res.render('cookie-test', {
    monster: monsterCookieValue
  });
});

app.get('/contest/vacation-photo', function(req, res) {
  var now;
  now = new Date();
  res.render('contest/vacation-photo', {
    year: now.getFullYear(),
    month: now.getMonth()
  });
});

app.post('/contest/vacation-photo/:year/:month', function(req, res) {
  var form;
  form = new formidable.IncomingForm();
  form.parse(req, function(err, fields, files) {
    if (err) {
      return res.redirect(303, '/error');
    }
    console.log('received fields:');
    console.log(fields);
    console.log('received files:');
    console.log(files);
    res.redirect(303, '/thank-you');
  });
});

app.get('/thank-you', function(req, res) {
  res.render('thank-you');
});

app.get('/newsletter', function(req, res) {
  res.render('newsletter', {
    csrf: 'CSRF token goes here'
  });
});

app.get('/newsletterAjax', function(req, res) {
  res.render('newsletterAjax', {
    csrf: 'CSRF token goes here'
  });
});

app.get('/archive', function(req, res) {
  res.render('archive');
});

app.post('/process', function(req, res) {
  console.log("Form (from querystring): " + req.query.form);
  console.log("CSRF token (from hidden form field): " + req.body._csrf);
  console.log("Name (from visible form field): " + req.body.name);
  console.log("Email (from visible form field): " + req.body.email);
  res.redirect(303, "/thank-you");
});

app.post('/processAjax', function(req, res) {
  if (req.xhr || req.accepts('json,html') === 'json') {
    res.send({
      success: true
    });
  } else {
    res.redirect(303, '/thank-you');
  }
});

app.get('/', function(req, res) {
  return res.render('home');
});

app.get('/about', function(req, res) {
  res.render('about', {
    fortune: fortune.getFortune()
  });
});

app.get('/headers', function(req, res) {
  var key, s, value, _ref;
  res.set('Content-Type', 'text/plain');
  s = '';
  _ref = req.headers;
  for (key in _ref) {
    value = _ref[key];
    s += (key + ": " + value) + '\n';
  }
  res.send(s);
});


/*
The static middleware allows you to designate one or
more directories as containing
static resources that are simply to be delivered to
the client without any special handling
 */

app.use(express["static"](__dirname + "/public"));

app.use(function(req, res) {
  res.type('text/plain');
  res.status(404);
  return res.send('404 - Not Found');
});

app.use(function(err, req, res, next) {
  console.log(err.stack);
  res.type('text/plain');
  res.status(500);
  return res.send('500 - Server Error');
});

app.listen(app.get('port'), function() {
  return console.log("Express started on http://localhost:" + (app.get('port')) + " ; press Ctrl-C to terminate.");
});

// ---
// generated by coffee-script 1.9.0
