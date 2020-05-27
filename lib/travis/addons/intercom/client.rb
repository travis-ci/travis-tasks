module Travis
  module Addons
    module Intercom

      class Client

        def initialize(user_id)
          @handle = Intercom::Client.new(token: Travis.config.intercom.token)
          @user = find_user(user_id)
        end

        def report_first_build(time = DateTime.now)
          @user.custom_attributes["first_build_at"] = time
          save
        end

        def report_last_build(time = DateTime.now)
          @user.custom_attributes["last_build_at"] = time
          save
        end

        private

        def find_user(id)
          begin
            @handle.users.find(user_id: id)
          rescue Intercom::ResourceNotFound {}
        end

        def save
          @handle.users.save(@user)
        end

      end

    end
  end
end