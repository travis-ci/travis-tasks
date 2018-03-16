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

    expect(asset_url(build_state)).to eq 'https://s3.amazonaws.com/travis-email-assets/passed.png'
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

    expect(broadcast_category(category)).to eq 'https://s3.amazonaws.com/travis-email-assets/announcement_dot.png'
  end

  it 'returns an warning broadcast status icon' do
    category = 'warning'

    expect(broadcast_category(category)).to eq 'https://s3.amazonaws.com/travis-email-assets/warning_dot.png'
  end

  it '#title returns title for the build' do
    expect(title(repository)).to eq 'Build Update for svenfuchs/minimal'
  end
end
