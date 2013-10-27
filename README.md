# Travis Notifications

Travis Notifications is a [Sidekiq](http://sidekiq.org/) based background processor whose main job is to send all manner of notifications based on events within Travis (job started, build finished).

These notifications are all queued up by state changes which are processed by [Travis Hub](https://github.com/travis-ci/travis-hub).

And, to make Travis Notifications even more special, there is no database connection required! Travis Notifications is all about talking to 3rd party services, if it be [Pusher](http://pusher.com), [Mandrill](https://mandrillapp.com), [Campfire](http://campfirenow.com/), or [S3](http://aws.amazon.com/s3/).

You can find the full list of notification services Travis natively talks to within [lib/travis/notifications/notifiers](https://github.com/travis-ci/travis-tasks/tree/master/lib/travis/notifications/notifiers).

Travis Tasks runs two processes, one which deals with all the addon services linked to above, and one which processes the S3 archiving.

![Travis Tasks Diagram](/img/diagram.jpg)

## License & copyright information ##

See LICENSE file.

Copyright (c) 2010-2013 [Travis CI development team](https://github.com/travis-ci).



