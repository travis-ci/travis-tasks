require 'intercom'

module Travis
  module Addons
    module Intercom
      class Client
        require 'travis/addons/intercom/client'

        def initialize(owner_id)
          @intercom = ::Intercom::Client.new(token: Travis.config.intercom.token)
          @user = get_user(owner_id)
        end

        def update_billing_data(params)
          return unless @user

          @user.custom_attributes['current_plan'] = params[:current_plan]
          @user.custom_attributes['public_credits_remaining'] = params[:public_credits_remaining]
          @user.custom_attributes['private_credits_remaining'] = params[:private_credits_remaining]
          @user.custom_attributes['last_build_triggered'] = params[:last_build_triggered]
          @user.custom_attributes['is_on_new_plan'] = params[:is_on_new_plan]
          @user.custom_attributes['renewal_date'] = params[:renewal_date]
          @user.custom_attributes['has_paid_plan'] = params[:has_paid_plan]
          @user.custom_attributes['orgs_admin_amount'] = params[:orgs_admin_amount]
          @user.custom_attributes['orgs_with_paid_plan_amount'] = params[:orgs_with_paid_plan_amount]
          update_user
        end

        def report_build(params)
          return unless @user
          @user.custom_attributes['fisrt_build_at'] = params[:fisrt_build_at] if params[:fisrt_build_at]
          @user.custom_attributes['last_build_at'] = params[:last_build_at]
          update_user
        end

        def report_subscription(params)
          return unless @user
          @user.custom_attributes['has_subscription'] = params[:has_subscription]
          update_user
        end

        private

        def get_user(id)
          @intercom.users.find(user_id: id)
        rescue ::Intercom::ResourceNotFound
          @intercom.users.create(user_id: id) # Create an empty user to save events, name and email will be added by other sources, e.g. web
        rescue ::Intercom::IntercomError
          nil
        end

        def update_user
          @intercom.users.save(@user)
        end
      end
    end
  end
end
