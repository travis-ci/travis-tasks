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

  context 'update_billing_data event' do
    let(:event_type) { 'update_billing_data' }
    let(:handler) { described_class.new({}, event: event_type, owner_id: owner_id, is_on_new_plan: is_on_new_plan, current_plan: current_plan, public_credits_remaining: public_credits_remaining, private_credits_remaining: private_credits_remaining, last_build_triggered: last_build_triggered, renewal_date: renewal_date, has_paid_plan: has_paid_plan, orgs_admin_amount: orgs_admin_amount, orgs_with_paid_plan_amount: orgs_with_paid_plan_amount)}
    let(:owner_id) { 1 }
    let(:is_on_new_plan) { true }
    let(:current_plan) { 'pro_tier_plan' }
    let(:public_credits_remaining) { 40_000 }
    let(:private_credits_remaining) { 500_000 }
    let(:last_build_triggered) { DateTime.now.strftime('%FT%T.%L%:z') }
    let(:renewal_date) { DateTime.now.strftime('%FT%T.%L%:z') }
    let(:has_paid_plan) { true }
    let(:orgs_admin_amount) { 1 }
    let(:orgs_with_paid_plan_amount) { 1 }
    let(:request_body) { "{\"custom_attributes\":{\"test\":\"1\",\"current_plan\":\"pro_tier_plan\",\"public_credits_remaining\":40000,\"private_credits_remaining\":500000,\"last_build_triggered\":\"#{last_build_triggered}\",\"is_on_new_plan\":true,\"renewal_date\":\"#{renewal_date}\",\"has_paid_plan\":true,\"orgs_admin_amount\":1,\"orgs_with_paid_plan_amount\":1},\"id\":\"1\",\"email\":\"test@test.com\",\"user_id\":\"1\"}" }

    it 'sends billing data to intercom' do
      Travis::Addons::Intercom::Client.any_instance.expects(event_type).with(
        event: event_type,
        owner_id: owner_id,
        is_on_new_plan: is_on_new_plan,
        current_plan: current_plan,
        public_credits_remaining: public_credits_remaining,
        private_credits_remaining: private_credits_remaining,
        last_build_triggered: last_build_triggered,
        renewal_date: renewal_date,
        has_paid_plan: has_paid_plan,
        orgs_admin_amount: orgs_admin_amount,
        orgs_with_paid_plan_amount: orgs_with_paid_plan_amount
      )
      handler.run
    end
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
