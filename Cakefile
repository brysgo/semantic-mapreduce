{spawn, exec} = require 'child_process'
log = console.log

task 'build', ->
  run 'coffee -o lib -c src/*.*coffee'
  
task 'watch', ->
  run 'coffee --watch -o lib -c src/*.*coffee'

task 'spec', ->
  run('cake watch')
  run('python -m SimpleHTTPServer')
  run('open http://localhost:8000/lib/SpecRunner.html')

task 'docs', ->
  run 'docco --layout \'linear\' src/funnel.coffee'

task 'docs:commit', ->
  run 'cake docs', ->
    run 'git checkout gh-pages', ->
      run 'git checkout master -- docs', ->
        run 'git commit -m\'Generate the docs\'', ->
          run 'git checkout master && git reset HEAD^'

run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a
  
  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0
