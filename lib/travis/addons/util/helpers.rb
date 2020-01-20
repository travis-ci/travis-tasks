require 'hashr'

module Travis
  module Addons
    module Util
      module Helpers
        extend self

        def vcs_prefix(vcs_type)
          vcs_type.sub('Repository', '').downcase if vcs_type
          'github'
        end

      end
    end
  end
end
