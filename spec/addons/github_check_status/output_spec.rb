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
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/1'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.1</a></td>
          <td>1.8.7</td>
          <td>passed</td>
        </tr>
        <tr>
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/2'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.2</a></td>
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
      Ruby Versions    | 1.8.7, 1.9.2

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

    example { is_expected.to eq({
      name:         'Travis CI - Branch',
      details_url:  'https://travis-ci.org/github/svenfuchs/minimal/builds/1',
      external_id:  '1',
      head_sha:     '62aae5f70ceee39123ef',
      started_at:   '2014-04-03T10:21:05Z',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    "<a href='https://travis-ci.org/github/svenfuchs/minimal/builds/1'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> The build</a> **passed**, just like the previous build.",
        text:       text
      }
    })}

    example { expect(subject[:output][:text]).to eq(text) }
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
      Ruby Version     | 1.8.7

      <details>
      <summary>Build Configuration</summary>
      <pre lang='yaml'>
      {
        "rvm": "1.8.7"
      }
      </pre>
      </details>
    MARKDOWN

    example { is_expected.to eq({
      name:         'Travis CI - Pull Request',
      details_url:  'https://travis-ci.org/github/svenfuchs/minimal/builds/1',
      external_id:  '1',
      head_sha:     'head-commit',
      started_at:   '2014-04-03T10:21:05Z',
      completed_at: '2014-04-03T10:22:05Z',
      conclusion:   'success',
      status:       'completed',
      output: {
        title:      'Build Passed',
        summary:    "<a href='https://travis-ci.org/github/svenfuchs/minimal/builds/1'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> The build</a> **passed**. This is a change from the previous build, which **failed**.",
        text:       text
      }
    })}

    example { expect(subject[:output][:text]).to eq(text) }
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
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/1'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.1</a></td>
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
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/2'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.2</a></td>
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
      Ruby Versions    | 1.8.7, 1.9.2

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

    example { expect(subject[:output][:text]).to eq(text) }
  end

  describe 'build with env data' do
    let(:payload) { TASK_PAYLOAD_WITH_ENVS.deep_symbolize_keys }
    let(:text)    { <<-MARKDOWN.gsub(/^      /, '').strip }
      This is a normal build for the master branch. You should be able to reproduce it by checking out the branch locally.

      ## Jobs and Stages
      This build has **two jobs**, running in parallel.

      <table>
      <thead>
        <tr>
          <th>Job</th>
          <th>Ruby</th>
          <th>ENV</th>
          <th>State</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/1'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.1</a></td>
          <td>1.8.7</td>
          <td>[secure]</td>
          <td>passed</td>
        </tr>
        <tr>
          <td><a href='https://travis-ci.org/github/svenfuchs/minimal/jobs/2'><img src='https://travis-ci.org/images/stroke-icons/icon-passed.png' height='11'> 2.2</a></td>
          <td>1.9.2</td>
          <td>x=y</td>
          <td>passed</td>
        </tr>
      </tbody>
      </table>

      ## Build Configuration

      Build Option     | Setting
      -----------------|--------------
      Language         | Ruby
      Operating System | Linux
      Ruby Versions    | 1.8.7, 1.9.2

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

    example { expect(subject[:output][:text]).to eq(text) }
  end

  describe 'queued build' do
    let(:payload) { base_payload.merge(build: base_payload[:build].merge(state: 'queued')) }
    let(:base_payload) { TASK_PAYLOAD.deep_symbolize_keys }

    example { expect(subject[:status]).to eq('queued') }
    example { expect(subject).not_to include(:conclusion) }
    example { expect(subject).not_to include(:completed_at) }
    example { expect(subject[:output][:summary]).to eq("<a href='https://travis-ci.org/github/svenfuchs/minimal/builds/1'><img src='https://travis-ci.org/images/stroke-icons/icon-running.png' height='11'> The build</a> is currently waiting in the build queue for a VM to be ready.") }
  end

  describe 'started build' do
    let(:payload) { base_payload.merge(build: base_payload[:build].merge(state: 'started')) }
    let(:base_payload) { TASK_PAYLOAD.deep_symbolize_keys }

    example { expect(subject[:status]).to eq('in_progress') }
    example { expect(subject).not_to include(:conclusion) }
    example { expect(subject).not_to include(:completed_at) }
    example { expect(subject[:output][:summary]).to eq("<a href='https://travis-ci.org/github/svenfuchs/minimal/builds/1'><img src='https://travis-ci.org/images/stroke-icons/icon-running.png' height='11'> The build</a> is currently running.") }
  end
end
