require 'spec_helper'

describe Travis::Addons::CheckStatus::Task do
  # include Travis::Testing::Stubs

  let(:payload) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:subject) { described_class.new(payload, installation: installation_id) }
  let(:installation_id) { '12345' }
  let(:slug) { 'svenfuchs/minimal' }
  let(:sha) { '62aae5f70ceee39123ef' }
  let(:response_data) { { check_run_id: 1, sha: sha, slug: slug } }

  before do
    ENV['GITHUB_PRIVATE_PEM'] = File.read('spec/fixtures/github_pem.txt')
    Travis.logger = Logger.new(StringIO.new)
  end

  after { ENV.delete('GITHUB_PRIVATE_PEM') }

  it 'creates a new check run if the build state is "created"' do
    payload['build']['state'] = 'created'

    resp = stub(success?: true, body: check_run_response(response_data), status: 200)
    Travis::RemoteVCS::Repository.any_instance.expects(:create_check_run).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'updates a check run' do
    payload['build']['state'] = 'passed'
    subject.expects(:find_check_run).returns(check_run_response(response_data))
    resp = stub(success?: true, body: check_run_response(response_data), status: 200)
    Travis::RemoteVCS::Repository.any_instance.expects(:check_runs).never
    Travis::RemoteVCS::Repository.any_instance.expects(:create_check_run).never
    Travis::RemoteVCS::Repository.any_instance.expects(:update_check_run).times(1).returns(resp)
    subject.expects(:info).times(2)

    subject.run
  end

  it 'informs when no check run is found' do
    payload['build']['state'] = 'passed'

    Travis::RemoteVCS::Repository.any_instance.expects(:create_check_run).never
    Travis::RemoteVCS::Repository.any_instance.expects(:update_check_run).never
    Travis::RemoteVCS::Repository.any_instance.expects(:check_runs).times(1).returns(stub(success?: false, status: 403))
    subject.expects(:info).times(1)
    subject.expects(:error).times(1)

    subject.run
  end
end

def check_run_list_response(data)
  "{
    \"total_count\": 1,
    \"check_runs\": [
      #{check_run_response(data)}
    ]
  }"
end

def check_run_response(data)
  '{
    "id": %{check_run_id},
    "sha": "%{sha}",
    "external_id": null,
    "url": "https://api.github.com/repos/%{slug}/check-runs/87",
    "html_url": "https://github.com/%{slug}/check_runs/87",
    "status": "completed",
    "conclusion": "neutral",
    "started_at": "2018-03-14T20:56:17Z",
    "completed_at": "2018-03-14T20:56:17Z",
    "output": {
      "title": "Report",
      "summary": "It\'s all good.",
      "text": "Optio sint doloremque sint natus aperiam rerum in. Et aut laboriosam omnis et. Sit dolor id quibusdam dolorem. Perspiciatis corporis et aut quia.",
      "annotations_count": 1,
      "annotations_url": null
    },
    "name": "randscape",
    "check_suite": {
      "id": 74
    },
    "app": {
      "id": 3,
      "owner": {
        "login": "github",
        "id": 342,
        "avatar_url": "http://alambic.github.localhost/avatars/u/342?",
        "gravatar_id": "",
        "url": "https://api.github.com/users/github",
        "html_url": "http://github.localhost/github",
        "followers_url": "https://api.github.com/users/github/followers",
        "following_url": "https://api.github.com/users/github/following{/other_user}",
        "gists_url": "https://api.github.com/users/github/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/github/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/github/subscriptions",
        "organizations_url": "https://api.github.com/users/github/orgs",
        "repos_url": "https://api.github.com/users/github/repos",
        "events_url": "https://api.github.com/users/github/events{/privacy}",
        "received_events_url": "https://api.github.com/users/github/received_events",
        "type": "Organization",
        "site_admin": false
      },
      "name": "Super Duper",
      "description": null,
      "external_url": "http://super-duper.example.com",
      "html_url": "http://github.localhost/apps/super-duper",
      "created_at": "2018-03-08 15:33:23 UTC",
      "updated_at": "2018-03-08 15:33:23 UTC"
    },
    "pull_request": {
      "url": "https://api.github.com/repos/%{slug}/pulls/1",
      "id": 1924,
      "head": {
        "ref": "say-hello",
        "sha": "7d424efbc9557be76d4d7ad9983f42ecf08d66d6",
        "repo": {
          "id": 1528,
          "url": "https://api.github.com/repos/%{slug}",
          "name": "Hello-World"
        }
      },
      "base": {
        "ref": "master",
        "sha": "cdf45260ae82a84f7ed5d3bce3d2400f2a1a0f24",
        "repo": {
          "id": 1528,
          "url": "https://api.github.com/repos/%{slug}",
          "name": "Hello-World"
        }
      }
    },
    "pull_requests": [{
      "url": "https://api.github.com/repos/%{slug}/pulls/1",
      "id": 1934,
      "head": {
        "ref": "say-hello",
        "sha": "3dca65fa3e8d4b3da3f3d056c59aee1c50f41390",
        "repo": {
          "id": 526,
          "url": "https://api.github.com/repos/%{slug}",
          "name": "hello-world"
        }
      },
      "base": {
        "ref": "master",
        "sha": "e7fdf7640066d71ad16a86fbcbb9c6a10a18af4f",
        "repo": {
          "id": 526,
          "url": "https://api.github.com/repos/%{slug}",
          "name": "hello-world"
        }
      }
    }]
  }' % data
end
