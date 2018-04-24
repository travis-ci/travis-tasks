require 'spec_helper'

describe Travis::Addons::GithubCheckStatus::Output do
  include Travis::Testing::Stubs
  let(:subject) { Travis::Addons::GithubCheckStatus::Output::Generator.new(payload).to_h }

  describe 'push build with matrix' do
    let(:payload) { TASK_PAYLOAD.deep_symbolize_keys }
    let(:text) { <<-MARKDOWN.gsub(/^      /, '').strip }
      This is a normal build for the master branch. You should be able to reproduce it by checking out the branch locally.

      ## Jobs and Stages
      This build has **two jobs**, running in parallel.

       Job                                                   | State
      -------------------------------------------------------|--------
       [2.1](https://travis-ci.org/svenfuchs/minimal/jobs/1) | passed
       [2.2](https://travis-ci.org/svenfuchs/minimal/jobs/2) | passed
    MARKDOWN

    example { should eq({
      name:         'Travis CI − master Branch',
      details_url:  'https://travis-ci.org/svenfuchs/minimal/builds/1',
      external_id:  1,
      branch:       'master',
      sha:          '62aae5f70ceee39123ef',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    'The build **[passed](https://travis-ci.org/svenfuchs/minimal/builds/1)** on Travis CI, just like the previous build.',
        text:       text
      }
    })}

    example { subject[:output][:text].should eq(text) }
  end

  describe 'pull request build with single job' do
    let(:payload) { TASK_PAYLOAD_PULL_REQUEST.deep_symbolize_keys }
    let(:text)    { <<-MARKDOWN.gsub(/^ +/, '').strip }
      This is a [pull request build](https://docs.travis-ci.com/user/pull-requests/).

      It is running a build against the merge commit, after merging [#1 (title)](https://github.com/svenfuchs/minimal/pull/1).
      Any changes that have been made to the master branch before the build ran are also included.

      ## Jobs and Stages
      This build only has a single job.
      You can use jobs to [test against multiple versions](https://docs.travis-ci.com/user/customizing-the-build/#Build-Matrix) of your runtime or dependencies, or to [speed up your build](https://docs.travis-ci.com/user/speeding-up-the-build/).
    MARKDOWN

    example { should eq({
      name:         'Travis CI − Pull Request',
      details_url:  'https://travis-ci.org/svenfuchs/minimal/builds/1',
      external_id:  1,
      branch:       'master',
      sha:          'head-commit',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    'The build **[passed](https://travis-ci.org/svenfuchs/minimal/builds/1)** on Travis CI. This is a change from the previous build, which **failed**.',
        text:       text
      }
    })}

    example { subject[:output][:text].should eq(text) }
  end

  describe 'build with stages' do
    let(:payload) { TASK_PAYLOAD_WITH_STAGES.deep_symbolize_keys }
    let(:text)    { <<-MARKDOWN.gsub(/^      /, '').strip }
      This is a normal build for the master branch. You should be able to reproduce it by checking out the branch locally.

      ## Jobs and Stages
      This build has **two jobs**, running in **two sequential stages**.

      ### Stage 1: Test
      This stage **passed**.

       Job                                                   | State
      -------------------------------------------------------|--------
       [2.1](https://travis-ci.org/svenfuchs/minimal/jobs/1) | passed

      ### Stage 2: Deploy
      This stage **passed**.

       Job                                                   | State
      -------------------------------------------------------|--------
       [2.2](https://travis-ci.org/svenfuchs/minimal/jobs/2) | passed
    MARKDOWN

    example { subject[:output][:text].should eq(text) }
  end
end
