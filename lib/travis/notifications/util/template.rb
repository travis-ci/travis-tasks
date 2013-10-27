require 'core_ext/hash/deep_symbolize_keys'
require "travis/notifications/util/result_message"

module Travis
  module Addons
    module Util
      class Template
        attr_reader :template, :data

        def initialize(template, data)
          @template = template
          @data = data.deep_symbolize_keys
        end

        def interpolate
          template.gsub(/%{(#{args.keys.join('|')}|.*)}/) { args[$1.to_sym] }
        end

        def args
          @args ||= {
            repository:     data[:repository][:slug],
            build_number:   data[:build][:number].to_s,
            build_id:       data[:build][:id].to_s,
            branch:         data[:commit][:branch],
            commit:         data[:commit][:sha][0..6],
            author:         data[:commit][:author_name],
            commit_message: data[:commit][:message],
            result:         data[:build][:state].to_s,
            message:        message,
            compare_url:    compare_url,
            build_url:      build_url
          }
        end

        def message
          ResultMessage.new(data[:build]).full
        end

        def compare_url
          data[:commit][:compare_url]
        end

        def build_url
          "http://#{Travis.config.host}/#{data[:repository][:slug]}/builds/#{data[:build][:id]}"
        end
      end
    end
  end
end
