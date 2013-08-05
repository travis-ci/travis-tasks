require 'travis'
Travis::Async.enabled = true
Travis::Database.connect

build = Build.last
Travis::Event::Handler::Pusher.notify('build:finished', build)
