# Travis Tasks
**************************

Travis Task is a [Sidekiq](http://sidekiq.org/) based background processor whose main job is to send all manner of notifications based on events within Travis (job started, build finished), as well as archiving logs to S3.

These notifications are all queued up by state changes which are processed by [Travis Hub](https://github.com/travis-ci/travis-hub).

And, to make Travis Tasks even more special, there is no database connection required! Travis Tasks is all about talking to 3rd party services, if it be [Pusher](http://pusher.com), [Mandrill](https://mandrillapp.com), [Campfire](http://campfirenow.com/), or [S3](http://aws.amazon.com/s3/).

You can find the full list of addon services Travis natively talks to within [Travis Core](https://github.com/travis-ci/travis-core/tree/master/lib/travis/addons).

Travis Tasks runs two processes, one which deals with all the addon services linked to above, and one which processes the S3 archiving.

![Travis Tasks Diagram](/img/diagram.jpg)

## Reporting Issues

Please file any issues on the [central Travis CI issue tracker](https://github.com/travis-ci/travis-ci/issues).

## License & copyright information ##

See LICENSE file.

Copyright (c) 2011 [Travis CI development team](https://github.com/travis-ci).



