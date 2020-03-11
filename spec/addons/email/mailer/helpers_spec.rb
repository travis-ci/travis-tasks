require 'spec_helper'

describe Travis::Addons::Email::Mailer::Helpers do
  include Travis::Addons::Email::Mailer::Helpers, Travis::Testing::Stubs

  it 'returns the organization name' do
    repository_slug = 'clark/superman'

    expect(organization_name(repository_slug)).to eq 'clark'
  end

  it 'returns repository name' do
    repository_slug = 'clark/superman'

    expect(repository_name(repository_slug)).to eq 'superman'
  end

  it 'returns a s3 asset url' do
    build_state = 'passed'

    expect(asset_url(build_state)).to eq "#{Travis.config.s3.url}/status-passed.png"
  end

  it 'returns gravatar url' do
    author_email = 'user@email.com'

    expect(gravatar_url(author_email)).to eq 'https://secure.gravatar.com/avatar/b58c6f14d292556214bd64909bcdb118'
  end

  it 'returns build status' do
    status_result = 'Build #1 has passed.'

    expect(build_status(status_result)).to eq 'Build #1 has passed'
  end

  it 'returns an announcement broadcast status icon' do
    category = 'announcement'

    expect(broadcast_category(category)).to eq "#{Travis.config.s3.url}/announcement_dot.png"
  end

  it 'returns an warning broadcast status icon' do
    category = 'warning'

    expect(broadcast_category(category)).to eq "#{Travis.config.s3.url}/warning_dot.png"
  end

  it '#title returns title for the build' do
    expect(title(repository)).to eq 'Build Update for svenfuchs/minimal'
  end

  it '#repository_url returns correct URL' do
    expect(repository_url(repository)).to match_url 'https://travis-ci.org/github/svenfuchs/minimal?utm_source=email&utm_medium=notification'
  end

  it '#repository_build_url returns correct URL' do
    expect(repository_build_url(slug: 'svenfuchs/minimal', vcs_slug: 'svenfuchs/minimal', id: 111, vcs_type: 'GithubRepository')).to match_url 'https://travis-ci.org/github/svenfuchs/minimal/builds/111?utm_source=email&utm_medium=notification'
  end

  it '#unsubscribe_url returns correct URL' do
    expect(unsubscribe_url).to match_url 'https://travis-ci.org/account/preferences/unsubscribe?utm_source=email&utm_medium=notification'
  end

  it '#repository_unsubscribe_url returns correct URL' do
    expect(repository_unsubscribe_url(repository)).to match_url "https://travis-ci.org/account/preferences/unsubscribe?utm_source=email&utm_medium=notification&repository=#{repository.id}"
  end
end
