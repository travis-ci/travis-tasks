# Travis Tasks
**************************

Travis Task is a [Sidekiq](http://sidekiq.org/) based background processor whose main job is to send all manner of notifications based on events within Travis (job started, build finished).

These notifications are all queued up by state changes which are processed by [Travis Hub](https://github.com/travis-ci/travis-hub) and [Travis Gatekeeper](https://github.com/travis-ci/travis-gatekeeper).

And, to make Travis Tasks even more special, there is no database connection required! Travis Tasks is all about talking to 3rd party services, if it be, [Mandrill](https://mandrillapp.com), [Campfire](http://campfirenow.com/), [Slack](http://slack.com/), or [Pushover](https://pushover.net/).

You can find the full list of addon services Travis natively talks to within [Travis Core](https://github.com/travis-ci/travis-core/tree/master/lib/travis/addons).

![Travis Tasks Diagram](/img/diagram.jpg)

## Reporting Issues

Please file any issues on the [central Travis CI issue tracker](https://github.com/travis-ci/travis-ci/issues).

## License & copyright information ##

See LICENSE file.

Copyright (c) 2011 [Travis CI development team](https://github.com/travis-ci).
