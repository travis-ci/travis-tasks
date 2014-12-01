require 'spec_helper'

describe Travis::Addons::Util::Template do
  include Travis::Testing::Stubs

  VAR_NAMES = %w(
    repository
    repository_slug
    repository_name
    build_number
    build_id
    branch
    commit
    author
    duration
    message
    compare_url
    build_url
    result
    pull_request
  )
  TEMPLATE  = VAR_NAMES.map { |name| "#{name}=%{#{name}}" }.join(' ')

  let(:data) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:template) { Travis::Addons::Util::Template.new(TEMPLATE.dup, data) }

  describe 'interpolation' do
    let(:result) { template.interpolate }

    it 'replaces the repository' do
      result.should =~ %r(repository=svenfuchs/minimal)
    end

    it 'replaces the repository slug' do
      result.should =~ %r(repository_slug=svenfuchs/minimal)
    end

    it 'replaces the repository name' do
      result.should =~ %r(repository_name=minimal)
    end

    it 'replaces the build_number' do
      result.should =~ /build_number=#{build.number}/
    end

    it "replaces the build_id" do
      result.should =~ /build_id=1/
    end

    it 'replaces the branch' do
      result.should =~ /branch=master/
    end

    it 'replaces the author' do
      result.should =~ /author=Sven Fuchs/
    end

    it 'replaces the duration' do
      result.should =~ /duration=1 min 0 sec/
    end

    it 'replaces the message' do
      result.should =~ /message=The build passed./
    end

    it 'replaces the pull request' do
      result.should =~ /pull_request=false/
    end
  end

  describe 'pull_request_url' do
    it 'returns nil when there is no pull request' do
      template.pull_request_url.should be_nil
    end

    it 'returns the pull request url based on the comparison url' do
      data = Marshal.load(Marshal.dump(TASK_PAYLOAD.merge({"build" => {"pull_request" => "1"}})))
      template = Travis::Addons::Util::Template.new(TEMPLATE.dup, data)

      expectation = "https://github.com/svenfuchs/minimal/pull/1"
      template.pull_request_url.should == expectation
    end
  end
end
