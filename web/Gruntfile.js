module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    // browserify: {
    //   dist: {
    //     options: {
    //       transform: [['babelify', {'stage': 0}]],
    //       browserifyOptions: {
    //         extensions: ['.jsx']
    //       },
    //       extensions: ['.jsx']
    //     },
    //     files: ['app.js']
    //   }
    // },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'app.js',
        dest: 'build/app.min.js'
      }
    },
    jshint: {
      app: {
        files: {
          src: ['app.js']
        }
      }
    },
    express: {
      options: {

      },
      dev: {
        options: {
          script: 'app.js'
        }
      }
    },
    watch: {
      options: {
        livereload: true
      },
      jshint: {
        files: {
          src: ['app.js']
        }
      },
      express: {
        files: ['app.js'],
        tasks: ['jshint', 'express:dev'],
        options: {
          spawn: false
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-express');
  grunt.loadNpmTasks('grunt-express-server');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-browserify');

  // Default task(s).
  grunt.registerTask('default', ['jshint', 'express:dev', 'watch']);

};