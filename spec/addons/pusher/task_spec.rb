# encoding: utf-8
require 'spec_helper'

module Support
  module Mocks
    module Pusher
      class Channel
        attr_accessor :messages

        def initialize
          @messages = []
        end

        def trigger(*args)
          messages << args
        end
        alias :trigger_async :trigger

        def reset!
          @messages = []
        end
        alias :clear! :reset!
      end
    end
  end
end

describe Travis::Addons::Pusher::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Pusher::Task }
  let(:channel) { Support::Mocks::Pusher::Channel.new }
  let(:task_payload) {Marshal.load(Marshal.dump(TASK_PAYLOAD))}

  before do
    Travis.config.notifications = [:pusher]
    Travis.pusher.stubs(:[]).returns(channel)
  end

  def run(event, object, options = {})
    type = event.sub('test:', '').sub(':', '/')
    payload = options[:params] ? task_payload.merge(options[:params]) : task_payload
    subject.new(payload, event: event).run
  end

  it 'logs Pusher errors and reraises' do
    channel.expects(:trigger).raises(Pusher::Error.new('message'))
    payload = task_payload.deep_symbolize_keys
    Travis.logger.expects(:error).with("[addons:pusher] Could not send event due to Pusher::Error: message, event=job:started, payload: #{payload.inspect}")

    expect {
      run('job:test:started', test)
    }.to raise_error(Pusher::Error)
  end

  describe 'run' do
    it 'job:test:finished' do
      run('job:test:finished', test)
      channel.should have_message('job:finished', test)
    end

    it 'build:finished' do
      run('build:finished', build)
      channel.should have_message('build:finished', build)
    end
  end

  describe 'channels' do
    describe 'for a private repo' do
      describe 'build event' do
        let(:data) { { 'build' => { 'id' => 1, 'repository_id' => 1, }, 'repository' => { 'id' => 1 } } }

        before :each do
          data['repository']['private'] = true
        end

        it 'includes "private-repo-1" for the event "build:finished"' do
          task = subject.new(data, :event => 'build:finished')
          task.channels.should include("private-repo-#{repository.id}")
        end
      end

      describe 'job event' do
        let(:data) { { 'id' => 1, 'build_id' => 1, 'repository_id' => 1 } }

        before :each do
          data['repository_private'] = true
        end

        it 'includes "private-repo-1" for the event "job:finished"' do
          task = subject.new(data, :event => 'job:test:finished')
          task.channels.should include("private-repo-#{repository.id}")
        end
      end
    end

    describe 'for a public repo' do
      describe 'with config.pusher.secure being false' do
        before :each do
          Travis.config.pusher.stubs(:secure?).returns(false)
        end

        describe 'build event' do
          let(:data) { { 'build' => { 'id' => 1, 'repository_id' => 1, }, 'repository' => { 'id' => 1 } } }

          before :each do
            data['repository']['private'] = false
          end

          it 'includes "repo-1" for the event "build:finished"' do
            task = subject.new(data, :event => 'build:finished')
            task.channels.should include('common')
          end
        end

        describe 'job event' do
          let(:data) { { 'id' => 1, 'build_id' => 1, 'repository_id' => 1 } }

          before :each do
            data['repository_private'] = false
          end

          it 'includes "repo-1" for the event "job:finished"' do
            task = subject.new(data, :event => 'job:test:finished')
            task.channels.should include('common')
          end
        end
      end

      describe 'with config.pusher.secure being true' do
        before :each do
          Travis.config.pusher.stubs(:secure?).returns(true)
        end

        describe 'build event' do
          let(:data) { { 'build' => { 'id' => 1, 'repository_id' => 1, }, 'repository' => { 'id' => 1 } } }

          before :each do
            data['repository']['private'] = false
          end

          it 'includes "private-repo-1" for the event "build:finished"' do
            task = subject.new(data, :event => 'build:finished')
            task.channels.should include("private-repo-#{repository.id}")
          end
        end

        describe 'build event' do
          let(:data) { { 'id' => 1, 'build_id' => 1, 'repository_id' => 1 } }

          before :each do
            data['repository_private'] = false
          end

          it 'includes "private-repo-1" for the event "job:finished"' do
            task = subject.new(data, :event => 'job:test:finished')
            task.channels.should include("private-repo-#{repository.id}")
          end
        end
      end
    end
  end
end
