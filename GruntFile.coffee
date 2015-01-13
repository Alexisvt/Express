path = require 'path'
port = 3000

module.exports = (grunt)->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      dist:
        files:
          'public/qa/tests-about.js' : 'public/qa/tests-about.coffee'
          'public/qa/tests-crosspage.js' : 'public/qa/tests-crosspage.coffee'
          'public/qa/tests-global.js' : 'public/qa/tests-global.coffee'
          
    open:
      all:
        path: 'http://localhost:' + port

    exec:
      openServer:
        cmd: 'coffee index.coffee'

    watch:
      coffee:
        files:'**/*.coffee'
        tasks: ['coffee']

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'coffee', [
    'watch'
  ]

  grunt.registerTask 'serve', [
    'open'
    'exec:openServer'
  ]
  return
return
