path = require 'path'
port = 3000

module.exports = (grunt)->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      dist:
        files:
          'index.js' : 'index.coffee'
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
    'exec:openServer'
    'open:all'
  ]
  return
return
