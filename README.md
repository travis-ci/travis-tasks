# Travis Tasks
**************************

Travis Task is a [Sidekiq](http://sidekiq.org/) based background processor whose main job is to send all manner of notifications based on events within Travis (job started, build finished).

These notifications are all queued up by state changes which are processed by [Travis Hub](https://github.com/travis-ci/travis-hub) and [Travis Gatekeeper](https://github.com/travis-ci/travis-gatekeeper).

And, to make Travis Tasks even more special, there is no database connection required! Travis Tasks is all about talking to 3rd party services, if it be, [Mandrill](https://mandrillapp.com), [Campfire](http://campfirenow.com/), [Slack](http://slack.com/), or [Pushover](https://pushover.net/).

You can find the full list of addon services Travis natively talks to within [Travis Core](https://github.com/travis-ci/travis-core/tree/master/lib/travis/addons).

![Travis Tasks Diagram](/img/diagram.jpg)

## Sending Trial Emails

### Start an Interactive Ruby Shell
```
irb -Ilib -rtravis/tasks
```

### Setup Config for SMTP By Running Each Command
```
Travis.config.smtp.address = 'smtp.mandrillapp.com'
Travis.config.smtp.domain = 'travis-ci.org'
Travis.config.smtp.enable_starttls_auto = true
Travis.config.smtp.password = 'your smtp password for your enviorment'
Travis.config.smtp.port = 587
Travis.config.smtp.user_name = 'your smtp username'
```
### Send Trial Email
```
Travis::Addons::Trial::Mailer::TrialMailer.trial_started(%w{your_email@address.com}, { name: 'Clark', login: 'github_username', billing_slug: 'user' }, 100).deliver
```

### Send Billing Emails
When a charge failed we call this method: `charge_failed(receivers, subscription, owner, charge, event, invoice, cc_last_digits)`

To check it and receive an email:

```
Travis::Addons::Billing::Mailer::BillingMailer.charge_failed( ["your_email@address.com"], { first_name: "Firstname", last_name: "Lastname", company: "Org", selected_plan: "travis-ci-two-builds"}, { name: 'Name', login: 'login' }, {"object": "charge"}, { "object": "invoice", "paid": false, "next_payment_attempt": Time.now + 86400.to_i  }, {"object": "invoice"}, {cc_last_digest: 1234}).deliver
```

We have the similar methods for: `invoice_payment_succeeded` and `subscription_cancelled`.

### Send Feedback Emails

When a user gives feedback after the cancellation that method gets called :`user_feedback(recipients, subscription, owner, user, feedback)`

To check it and receive an email at: `success@travis-ci.org`:

```
Travis::Addons::BillingFeedback::Mailer::BillingFeedbackMailer.user_feedback( ["your_email@address.com"], {first_name: "Firstname", last_name: "Lastname", company: "Org", selected_plan: "travis-ci-two-builds", valid_to: Time.now }, { name: 'Name', login: 'login' }, {name: 'user', login: 'userlogin', email: "your_email@address.com" }, {"feedback": "test"}).deliver
```


## Reporting Issues

Please file any issues on the [central Travis CI issue tracker](https://github.com/travis-ci/travis-ci/issues).

## License & copyright information ##

See LICENSE file.

Copyright (c) 2011 [Travis CI development team](https://github.com/travis-ci).
