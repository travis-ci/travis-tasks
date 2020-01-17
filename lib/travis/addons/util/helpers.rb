require 'hashr'

module Travis
  module Addons
    module Util
      class Helpers

        def vcs_prefix(vcs_type)
          vcs_type.sub('Repository', '').downcase if vcs_type
        end

      end
    end
  end
end
