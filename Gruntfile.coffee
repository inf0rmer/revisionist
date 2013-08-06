module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    rig:
      wrap:
        src: ['src/wrapper.coffee']
        dest: 'dist/<%= pkg.name %>.coffee'

    coffee:
      specs:
        files:
          'spec/revisionistSpec.js': 'spec/revisionistSpec.coffee'

    uglify:
      options:
        banner: '/**\n' +
              ' * <%= pkg.title %> v<%= pkg.version %>\n' +
              ' *\n' +
              ' * Copyright (c) <%= grunt.template.today("yyyy") %>' +
              '<%= pkg.author %>\n' +
              ' * Distributed under MIT License\n' +
              ' *\n' +
              ' * Documentation and full license available at:\n' +
              ' * <%= pkg.homepage %>\n' +
              ' *\n' +
              ' */\n'
        report: 'gzip'
        mangle:
          except: ['Revisionist']
      browser:
        files:
          'dist/<%= pkg.name %>.min.js': ['dist/<%= pkg.name %>.js']

    watch:
      files: '<%= coffeelint.files %>'
      tasks: ['default']

    coffeelint:
      files: ['Gruntfile.coffee', 'src/**/*.coffee']
      options:
        max_line_length:
          level: 'ignore'

    jasmine:
      test:
        options:
          specs: 'spec/*Spec.js',
          template: require('grunt-template-jasmine-requirejs'),
          templateOptions:
            requireConfig:
              baseUrl: '.',
              paths:
                "revisionist": "dist/revisionist"

    docco:
      docs:
        src: 'src/revisionist.coffee'
        options:
          output: 'docs/'

    browserify:
      'dist/revisionist.js': ['src/revisionist.coffee']
      options:
        transform: ['coffeeify']
        standalone: 'Revisionist'

  grunt.registerTask 'default', ['coffeelint']
  grunt.registerTask 'build', [
    'coffeelint',
    'browserify',
    'uglify'
  ]
  grunt.registerTask 'test', ['build', 'coffee:specs', 'jasmine']
  grunt.registerTask 'docs', ['docco']

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-rigger'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-docco'
  grunt.loadNpmTasks 'grunt-browserify'
