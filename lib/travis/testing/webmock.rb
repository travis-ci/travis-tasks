require 'active_support'
require 'webmock'
require 'webmock/rspec'
require 'uri'

module Travis
  module Support
    module Testing
      module Webmock
        extend ActiveSupport::Concern

        included do
          before :each do
            Travis::Support::Testing::Webmock.mock!
            WebMock.disable_net_connect!
          end
        end

        class MockRequest
          attr_reader :uri, :stub

          def initialize(url)
            @uri = URI.parse(url)
          end

          def response
            { :status => 200, :body => body, :headers => {} }
          end

          private

            def body
              store unless stored?
              File.read(filename)
            end

            def store
              puts "Storing #{uri.to_s} to #{filename}."
              `curl -so #{filename} --create-dirs #{uri.to_s}`
            end

            def stored?
              File.exists?(filename)
            end

            def filename
              @filename ||= "spec/fixtures/github/#{escape(path)}"
            end

            def path
              path = uri.path
              path += "?#{uri.query}" if uri.query
              "#{uri.host}#{path}.json"
            end

            def escape(path)
              path.gsub(/[^\w\.\-\/]+/, '_')
            end
        end

        class << self
          attr_reader :requests

          def mock!
            @requests = {}
            WebMock.stub_request(:get, %r(https?://(?!127.0.0.1|localhost))).to_return do |request|
              uri = request.uri
              request = MockRequest.new(uri)
              @requests[uri] = request
              request.response
            end
          end
        end

        def requests
          Travis::Support::Testing::Webmock.requests
        end
      end
    end
  end
end
