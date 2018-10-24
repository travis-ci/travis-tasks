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
    pull_request_number
  )
  TEMPLATE  = VAR_NAMES.map { |name| "#{name}=%{#{name}}" }.join(' ')

  let(:data) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:template) { Travis::Addons::Util::Template.new(TEMPLATE.dup, data) }

  describe 'interpolation' do
    let(:result) { template.interpolate }

    it 'replaces the repository' do
      expect(result).to match(%r(repository=svenfuchs/minimal))
    end

    it 'replaces the repository slug' do
      expect(result).to match(%r(repository_slug=svenfuchs/minimal))
    end

    it 'replaces the repository name' do
      expect(result).to match(%r(repository_name=minimal))
    end

    it 'replaces the build_number' do
      expect(result).to match(/build_number=#{build.number}/)
    end

    it "replaces the build_id" do
      expect(result).to match(/build_id=1/)
    end

    it 'replaces the branch' do
      expect(result).to match(/branch=master/)
    end

    it 'replaces the author' do
      expect(result).to match(/author=Sven Fuchs/)
    end

    it 'replaces the duration' do
      expect(result).to match(/duration=1 min 0 sec/)
    end

    it 'replaces the message' do
      expect(result).to match(/message=The build passed./)
    end

    it 'replaces the pull request' do
      expect(result).to match(/pull_request=false/)
    end

    it 'replaces the pull request number' do
      expect(result).to match(/pull_request_number=/)
    end

    it "doesn't generate a pull request url" do
      expect(template.pull_request_url).to be_nil
    end
  end

  describe 'interpolation for pull requests' do
    let(:payload) do
      payload = Marshal.load(Marshal.dump(TASK_PAYLOAD))
      payload["build"].merge!({"pull_request" => "true", "pull_request_number" => "1"})
      payload
    end

    let(:data) { Marshal.load(Marshal.dump(payload)) }
    let(:template) { Travis::Addons::Util::Template.new(TEMPLATE.dup, data) }

    let(:result) { template.interpolate }

    it 'replaces the pull request' do
      expect(result).to match(/pull_request=true/)
    end

    it 'replaces the pull request number' do
      expect(result).to match(/pull_request_number=1/)
    end

    it 'generates the pull request url based on the comparison url' do
      expectation = "https://github.com/svenfuchs/minimal/pull/1"
      expect(template.pull_request_url).to eq(expectation)
    end
  end
end
