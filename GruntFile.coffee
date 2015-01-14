path = require 'path'
port = 3000

module.exports = (grunt)->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      expand: true
      flatten: true
      cwd: 'public/qa/'
      src: ['*.coffee']
      dest: 'public/qa/'
      ext: '.js'

    open:
      all:
        path: "http://localhost:#{port}"

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
