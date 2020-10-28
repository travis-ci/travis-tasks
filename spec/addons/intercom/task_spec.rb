require 'spec_helper'

describe Travis::Addons::Intercom::Task do
  let(:subject) { Travis::Addons::Intercom::Task }

  before do
    stub_request(:get, 'https://api.intercom.io/users?user_id=1').
      with(
        headers: {
          'Accept'=>'application/vnd.intercom.3+json',
          'Accept-Encoding'=>'gzip, deflate',
          'Acceptencoding'=>'gzip, deflate',
          'Authorization'=>'Basic dG9rZW46',
          'User-Agent'=>'Intercom-Ruby/3.8.1'
        }).to_return(status: 200, body: JSON.dump(
          "type" =>"user",
          "id" =>"1",
          "user_id" => '1',
          "email" => 'test@test.com',
          "name" => "Test User",
          "app_id" => "token",
          "custom_attributes" => {"test" => "1"}
        ))
    stub_request(:post, "https://api.intercom.io/users").
      with(
        body: request_body,
        headers: {
          'Accept'=>'application/vnd.intercom.3+json',
          'Accept-Encoding'=>'gzip, deflate',
          'Acceptencoding'=>'gzip, deflate',
          'Authorization'=>'Basic dG9rZW46',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Intercom-Ruby/3.8.1'
        }).to_return(status: 200, body: JSON.dump(
          "email" => "test@test.com",
          "user_id" => "1"
        ))
  end

  context 'report_build event' do
    let(:event_type) { 'report_build' }
    let(:handler) { described_class.new({}, event: event_type, owner_id: owner_id, last_build_at: last_build_at)}
    let(:owner_id) { 1 }
    let(:last_build_at) { DateTime.now.strftime('%FT%T.%L%:z') }
    let(:request_body) { "{\"custom_attributes\":{\"test\":\"1\",\"last_build_at\":\"#{last_build_at}\"},\"id\":\"1\",\"email\":\"test@test.com\",\"user_id\":\"1\"}" }

    it 'sends build data to intercom' do
      Travis::Addons::Intercom::Client.any_instance.expects(event_type).with(
        event: event_type,
        owner_id: owner_id,
        last_build_at: last_build_at
      )
      handler.run
    end
  end

  context 'report_subscription event' do
    let(:event_type) { 'report_subscription' }
    let(:handler) { described_class.new({}, event: event_type, owner_id: owner_id, has_subscription: has_subscription)}
    let(:owner_id) { 1 }
    let(:has_subscription) { true }
    let(:request_body) { "{\"custom_attributes\":{\"test\":\"1\",\"has_subscription\":\"#{has_subscription}\"},\"id\":\"1\",\"email\":\"test@test.com\",\"user_id\":\"1\"}" }

    it 'sends subscription data to intercom' do
      Travis::Addons::Intercom::Client.any_instance.expects(event_type).with(
        event: event_type,
        owner_id: owner_id,
        has_subscription: has_subscription
      )
      handler.run
    end
  end
end
