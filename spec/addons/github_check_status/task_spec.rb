require 'spec_helper'

describe Travis::Addons::GithubCheckStatus::Task do
  include Travis::Testing::Stubs

  before { ENV['GITHUB_PRIVATE_PEM'] = File.read('spec/fixtures/github_pem.txt') }
  after  { ENV.delete('GITHUB_PRIVATE_PEM') }

  let(:subject)    { Travis::Addons::GithubCheckStatus::Task.new(payload, installation: installation_id) }
  let(:payload)    { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:io)         { StringIO.new }
  let(:gh_apps)    { Travis::GithubApps.new installation_id }
  let(:installation_id) { '12345' }

  let(:slug) { 'svenfuchs/minimal' }
  let(:sha) { '62aae5f70ceee39123ef' }
  let(:response_data) { {check_run_id: 1, sha: sha, slug: slug} }

  let(:conn) {
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post("app/installations/12345/access_tokens") { |env| [201, {}, "{\"token\":\"github_apps_access_token\",\"expires_at\":\"2018-04-03T20:52:14Z\"}"] }
        stub.post("/repositories/549743/check-runs") { |env| [201, {}, check_run_response(response_data)] }
        stub.get("/repositories/549743/commits/#{sha}/check-runs?check_name=Travis+CI+-+Branch&filter=all") { |env| [200, {}, check_run_list_response(response_data)] }
        stub.patch("/repositories/549743/check-runs/1") { |env| [200, {}, check_run_response(response_data)] }
      end
    end
  }

  before do
    Travis.logger = Logger.new(io)
  end

  it 'makes expected API calls' do
    Travis::Backends::Github.any_instance.expects(:github_apps).times(1).returns(gh_apps)
    gh_apps.expects(:github_api_conn).times(2).returns(conn)
    subject.run
  end

  context "when API call to fetch Check Runs fails" do

    let(:conn) {
      Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post("app/installations/12345/access_tokens") { |env| [201, {}, "{\"token\":\"github_apps_access_token\",\"expires_at\":\"2018-04-03T20:52:14Z\"}"] }
          stub.post("/repositories/549743/check-runs") { |env| [201, {}, check_run_response(response_data)] }
          stub.get("/repositories/549743/commits/#{sha}/check-runs?check_name=Travis+CI+-+Branch&filter=all") { |env| [403, {}, check_run_list_response(response_data)] }
          stub.patch("/repositories/549743/check-runs/1") { |env| [200, {}, check_run_response(response_data)] }
        end
      end
    }

    it 'makes expected API calls' do
      Travis::Backends::Github.any_instance.expects(:github_apps).times(1).returns(gh_apps)
      gh_apps.expects(:github_api_conn).times(2).returns(conn)
      subject.run
    end
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
