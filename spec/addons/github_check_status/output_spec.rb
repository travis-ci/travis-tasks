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

      <table>
      <thead>
        <tr>
          <th>Job</th>
          <th>Ruby</th>
          <th>State</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> <a href='https://travis-ci.org/svenfuchs/minimal/jobs/1'>2.1</a></td>
          <td>1.8.7</td>
          <td>passed</td>
        </tr>
        <tr>
          <td><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> <a href='https://travis-ci.org/svenfuchs/minimal/jobs/2'>2.2</a></td>
          <td>1.9.2</td>
          <td>passed</td>
        </tr>
      </tbody>
      </table>

      ## Build Configuration

      Build Option     | Setting
      -----------------|--------------
      Language         | Ruby
      Operating System | Linux
      Sudo Access      | not required
      Ruby Versions    | 1.8.7, 1.9.2

      It's using the default test runner for Ruby.

      <details>
      <summary>Build Configuration</summary>
      <pre lang='yaml'>
      {
        "rvm": [
          "1.8.7",
          "1.9.2"
        ]
      }
      </pre>
      </details>
    MARKDOWN

    example { should eq({
      name:         'Travis CI - Branch',
      details_url:  'https://travis-ci.org/svenfuchs/minimal/builds/1',
      external_id:  '1',
      head_sha:     '62aae5f70ceee39123ef',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    "<img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> The build **passed**, just like the previous build.",
        text:       text
      }
    })}

    example { subject[:output][:text].should eq(text) }
  end

  describe 'pull request build with single job' do
    let(:payload) { TASK_PAYLOAD_PULL_REQUEST.deep_symbolize_keys }
    let(:text)    { <<-MARKDOWN.gsub(/^      /, '').strip }
      This is a [pull request build](https://docs.travis-ci.com/user/pull-requests/).

      It is running a build against the merge commit, after merging [#1 title](https://github.com/svenfuchs/minimal/pull/1).
      Any changes that have been made to the master branch before the build ran are also included.

      ## Jobs and Stages
      This build only has a single job.
      You can use jobs to [test against multiple versions](https://docs.travis-ci.com/user/customizing-the-build/#Build-Matrix) of your runtime or dependencies, or to [speed up your build](https://docs.travis-ci.com/user/speeding-up-the-build/).

      ## Build Configuration

      Build Option     | Setting
      -----------------|--------------
      Language         | Ruby
      Operating System | Linux
      Sudo Access      | not required
      Ruby Version     | 1.8.7

      It's using the default test runner for Ruby.

      <details>
      <summary>Build Configuration</summary>
      <pre lang='yaml'>
      {
        "rvm": "1.8.7"
      }
      </pre>
      </details>
    MARKDOWN

    example { should eq({
      name:         'Travis CI - Pull Request',
      details_url:  'https://travis-ci.org/svenfuchs/minimal/builds/1',
      external_id:  '1',
      head_sha:     'head-commit',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    "<img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> The build **passed**. This is a change from the previous build, which **failed**.",
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

      <table>
      <thead>
        <tr>
          <th>Job</th>
          <th>Ruby</th>
          <th>State</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> <a href='https://travis-ci.org/svenfuchs/minimal/jobs/1'>2.1</a></td>
          <td>1.8.7</td>
          <td>passed</td>
        </tr>
      </tbody>
      </table>

      ### Stage 2: Deploy
      This stage **passed**.

      <table>
      <thead>
        <tr>
          <th>Job</th>
          <th>Ruby</th>
          <th>State</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> <a href='https://travis-ci.org/svenfuchs/minimal/jobs/2'>2.2</a></td>
          <td>1.9.2</td>
          <td>passed</td>
        </tr>
      </tbody>
      </table>

      ## Build Configuration

      Build Option     | Setting
      -----------------|--------------
      Language         | Ruby
      Operating System | Linux
      Sudo Access      | not required
      Ruby Versions    | 1.8.7, 1.9.2

      It's using the default test runner for Ruby.

      <details>
      <summary>Build Configuration</summary>
      <pre lang='yaml'>
      {
        "rvm": [
          "1.8.7",
          "1.9.2"
        ]
      }
      </pre>
      </details>
    MARKDOWN

    example { subject[:output][:text].should eq(text) }
  end

  describe 'queued build' do
    let(:payload) { base_payload.merge(build: base_payload[:build].merge(state: 'queued')) }
    let(:base_payload) { TASK_PAYLOAD.deep_symbolize_keys }

    example { subject[:status].should be == 'queued' }
    example { subject.should_not include(:conclusion) }
    example { subject.should_not include(:completed_at) }
    example { subject[:output][:summary].should be == "<img src='https://travis-ci.org/images/stroke-icons/icon-running.png' height='11'> The build is currently waiting in the build queue for a VM to be ready." }
  end

  describe 'started build' do
    let(:payload) { base_payload.merge(build: base_payload[:build].merge(state: 'started')) }
    let(:base_payload) { TASK_PAYLOAD.deep_symbolize_keys }

    example { subject[:status].should be == 'in_progress' }
    example { subject.should_not include(:conclusion) }
    example { subject.should_not include(:completed_at) }
    example { subject[:output][:summary].should be == "<img src='https://travis-ci.org/images/stroke-icons/icon-running.png' height='11'> The build is currently running." }
  end
end
