# Travis Tasks
**************************

Travis Task is a [Sidekiq](http://sidekiq.org/) based background processor whose main job is to send all manner of notifications based on events within Travis (job started, build finished).

These notifications are all queued up by state changes which are processed by [Travis Hub](https://github.com/travis-ci/travis-hub) and [Travis Gatekeeper](https://github.com/travis-ci/travis-gatekeeper).

And, to make Travis Tasks even more special, there is no database connection required! Travis Tasks is all about talking to 3rd party services, if it be, [Mandrill](https://mandrillapp.com), [Campfire](http://campfirenow.com/), [Slack](http://slack.com/), or [Pushover](https://pushover.net/).

You can find the full list of addon services Travis natively talks to within [Travis Core](https://github.com/travis-ci/travis-core/tree/master/lib/travis/addons).

![Travis Tasks Diagram](/img/diagram.jpg)

## Sending Email Setup

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

or
```
ActionMailer::Base.smtp_settings = {
  address: "smtp.mandrillapp.com",
  user_name: "mathias@travis-ci.com",
  password: <have a look in keychain>,
  domain: "travis-ci.com",
  enable_starttls_auto: true,
  port: 587
}
```

## Send Build Emails
To send diffent types of build emails the `state`, `previous_state` attributes in the build hash and `state` attribute job hash will need to be modified

You can send email to multiple addresses by adding them to the array following the `jobs` hash
### Success Build
```
Travis::Addons::Email::Mailer::Build.finished_email({ build: {id: 1, repository_id: 1, commit_id: 1, number: 2, pull_request: false, config: {rvm: ['1.8.7, 1.9.2']}, state: 'passed', previous_state: 'passed', started_at: '2014-04-03T10:21:05Z', finished_at: '2014-04-03T10:22:05Z', duration: 60, jobs_ids: [1, 2], type: 'push'}, repository: {id: 1, key: '-----BEGIN PUBLIC KEY-----', slug: 'wonderfulPerson/minimal', name: 'minimal', owner_name: 'wonderPerson', owner_email: 'someone@internet.com', owner_avatar_url: nil, url: 'repo url here}, commit: {id: 1, sha: '62aae5f70ceee39123ef', branch: 'this-branch-is-awesome', message: 'the commit message', committed_at: '2014-04-03T09:22:05Z', author_name: 'Wonderful Person', author_email: 'someone@internet.com', committer_name: 'Wonderful Person', committer_email: 'someone@internet.com', compare_url: 'https://github.com/wonderfulperson/minimal/compare/master...develop'}, jobs: [{id: 1, number: '2.1', state: 'passed', config: {rvm: '1.8.7'}}]},['recipient@internet.com'],[{message: 'Testing testing this is a message', category: 'announcement'}, {message: 'Testing testing this is a message', category: 'warning'}]).deliver
```

### Failed Build
```
Travis::Addons::Email::Mailer::Build.finished_email({ build: {id: 1, repository_id: 1, commit_id: 1, number: 2, pull_request: false, config: {rvm: ['1.8.7, 1.9.2']}, state: 'failed', previous_state: 'passed', started_at: '2014-04-03T10:21:05Z', finished_at: '2014-04-03T10:22:05Z', duration: 60, jobs_ids: [1, 2], type: 'push'}, repository: {id: 1, key: '-----BEGIN PUBLIC KEY-----', slug: 'wonderfulPerson/minimal', name: 'minimal', owner_name: 'wonderPerson', owner_email: 'someone@internet.com', owner_avatar_url: nil, url: 'repo url here}, commit: {id: 1, sha: '62aae5f70ceee39123ef', branch: 'this-branch-is-awesome', message: 'the commit message', committed_at: '2014-04-03T09:22:05Z', author_name: 'Wonderful Person', author_email: 'someone@internet.com', committer_name: 'Wonderful Person', committer_email: 'someone@internet.com', compare_url: 'https://github.com/wonderfulperson/minimal/compare/master...develop'}, jobs: [{id: 1, number: '2.1', state: 'failed', config: {rvm: '1.8.7'}}]},['recipient@internet.com'],[{message: 'Testing testing this is a message', category: 'announcement'}, {message: 'Testing testing this is a message', category: 'warning'}]).deliver
```

### Still Failing Build
```
Travis::Addons::Email::Mailer::Build.finished_email({ build: {id: 1, repository_id: 1, commit_id: 1, number: 2, pull_request: false, config: {rvm: ['1.8.7, 1.9.2']}, state: 'failed', previous_state: 'failed', started_at: '2014-04-03T10:21:05Z', finished_at: '2014-04-03T10:22:05Z', duration: 60, jobs_ids: [1, 2], type: 'push'}, repository: {id: 1, key: '-----BEGIN PUBLIC KEY-----', slug: 'wonderfulPerson/minimal', name: 'minimal', owner_name: 'wonderPerson', owner_email: 'someone@internet.com', owner_avatar_url: nil, url: 'repo url here}, commit: {id: 1, sha: '62aae5f70ceee39123ef', branch: 'this-branch-is-awesome', message: 'the commit message', committed_at: '2014-04-03T09:22:05Z', author_name: 'Wonderful Person', author_email: 'someone@internet.com', committer_name: 'Wonderful Person', committer_email: 'someone@internet.com', compare_url: 'https://github.com/wonderfulperson/minimal/compare/master...develop'}, jobs: [{id: 1, number: '2.1', state: 'failed', config: {rvm: '1.8.7'}}]},['recipient@internet.com'],[{message: 'Testing testing this is a message', category: 'announcement'}, {message: 'Testing testing this is a message', category: 'warning'}]).deliver
```

### Error Build
```
Travis::Addons::Email::Mailer::Build.finished_email({ build: {id: 1, repository_id: 1, commit_id: 1, number: 2, pull_request: false, config: {rvm: ['1.8.7, 1.9.2']}, state: 'errored', previous_state: 'passed', started_at: '2014-04-03T10:21:05Z', finished_at: '2014-04-03T10:22:05Z', duration: 60, jobs_ids: [1, 2], type: 'push'}, repository: {id: 1, key: '-----BEGIN PUBLIC KEY-----', slug: 'wonderfulPerson/minimal', name: 'minimal', owner_name: 'wonderPerson', owner_email: 'someone@internet.com', owner_avatar_url: nil, url: 'repo url here}, commit: {id: 1, sha: '62aae5f70ceee39123ef', branch: 'this-branch-is-awesome', message: 'the commit message', committed_at: '2014-04-03T09:22:05Z', author_name: 'Wonderful Person', author_email: 'someone@internet.com', committer_name: 'Wonderful Person', committer_email: 'someone@internet.com', compare_url: 'https://github.com/wonderfulperson/minimal/compare/master...develop'}, jobs: [{id: 1, number: '2.1', state: 'errored', config: {rvm: '1.8.7'}}]},['recipient@internet.com'],[{message: 'Testing testing this is a message', category: 'announcement'}, {message: 'Testing testing this is a message', category: 'warning'}]).deliver
```

## Send Trial Emails
```
Travis::Addons::Trial::Mailer::TrialMailer.trial_started(%w{your_email@address.com}, { name: 'Clark', login: 'github_username', billing_slug: 'user' }, 100).deliver
```

## Send Billing Emails
When a charge failed we call this method: `charge_failed(receivers, subscription, owner, charge, event, invoice, cc_last_digits)`

To check it and receive an email:

```
Travis::Addons::Billing::Mailer::BillingMailer.charge_failed( ["your_email@address.com"], { first_name: "Firstname", last_name: "Lastname", company: "Org", selected_plan: "travis-ci-two-builds"}, { name: 'Name', login: 'login', owner_type: 'User' }, {"object": "charge"}, { "object": "invoice", "paid": false, "next_payment_attempt": Time.now + 86400.to_i  }, {"object": "invoice"}, {cc_last_digest: 1234}).deliver
```

invoice_payment_succeeded:
```
Travis::Addons::Billing::Task.new({}, email_type: 'invoice_payment_succeeded', recipients: ["name@travis-ci.org"], subscription: { first_name: "Marie", last_name: "Lastname"}, owner: { name: 'Marie', login: 'login', owner_type: 'User' }, charge: {"charge": nil}, event: {"event": nil}, invoice: {"object": {<stripe_invoice_event>},"created_at": "2019-06-07 10:50:45", current_period_start: 1.day.ago.utc.to_i, current_period_end: 30.day.from_now.utc.to_i, plan: "Bootstrap", amount: 6900, invoice_id: "TP1234", stripe_id: "in_1234" }, cc_last_digits: 1234).run
```

We have the similar methods for: `subscription_cancelled`.

## Send Feedback Emails

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

