module Travis
  module Addons
    module CheckStatus
      require 'travis/addons/check_status/task'

      module Output
        require 'travis/addons/check_status/output/helpers'
        require 'travis/addons/check_status/output/generator'
        require 'travis/addons/check_status/output/templates'
        require 'travis/addons/check_status/output/pull_request'
        require 'travis/addons/check_status/output/push'
        require 'travis/addons/check_status/output/single_job'
        require 'travis/addons/check_status/output/matrix'
        require 'travis/addons/check_status/output/stage'
      end
    end
  end
end
