module Travis::Addons::GithubCheckStatus::Output
  module Helpers
    STATUS = {
      'created'  => 'queued',
      'queued'   => 'queued',
      'started'  => 'in_progress',
      'passed'   => 'completed',
      'failed'   => 'completed',
      'errored'  => 'completed',
      'canceled' => 'completed',
    }

    CONCLUSION = {
      'passed'   => 'success',
      'failed'   => 'failure',
      'errored'  => 'action_required',
      'canceled' => 'neutral',
    }

    ICON = {
      'created'  => 'icon-running.png',
      'queued'   => 'icon-running.png',
      'started'  => 'icon-running.png',
      'passed'   => 'icon-passed.png',
      'failed'   => 'icon-failed.png',
      'errored'  => 'icon-errored.png',
      'canceled' => 'icon-canceled.png',
    }

    DEFAULT_LANGUAGE = 'RUBY'
    LANGUAGES        = {
      go:               'Go',
      php:              'PHP',
      node_js:          'Node.js',
      perl:             'Perl',
      perl6:            'Perl6',
      python:           'Python',
      scala:            'Scala',
      smalltalk:        'Smalltalk',
      smalltalk_config: 'Config',
      ruby:             'Ruby',
      d:                'D',
      julia:            'Julia',
      csharp:           'C#',
      mono:             'Mono',
      dart:             'Dart',
      dart_task:        'Task',
      elixir:           'Elixir',
      ghc:              'GHC',
      haxe:             'Haxe',
      jdk:              'JDK',
      rvm:              'Ruby',
      otp_release:      'OTP Release',
      rust:             'Rust',
      c:                'C',
      cpp:              'C++',
      clojure:          'Clojure',
      lein:             'Lein',
      compiler:         'Compiler',
      crystal:          'Crystal',
      osx_image:        'Xcode',
      r:                'R',
      nix:              'Nix'
    }

    OTHER_KEYS = {
      env:          'ENV',
      gemfile:      'Gemfile',
      xcode_sdk:    'Xcode SDK',
      xcode_scheme: 'Xcode Scheme',
      compiler:     'Compiler',
      os:           'OS'
    }

    MATRIX_KEYS        = LANGUAGES.merge(OTHER_KEYS)
    SPECIAL_CHARACTERS = "<>*/\\'_[]#~"
    ESCAPE_MATCHER     = /[#{Regexp.escape(SPECIAL_CHARACTERS)}]/
    NUMBERS            = %w[zero one two three four five six seven eight nine ten]

    def self.hash_accessors(method, *fields)
      fields.each do |field|
        field = { field => field } unless field.is_a? Hash
        field.each { |k,v| module_eval "def #{k}; #{method}[:#{v}]; end" }
      end
    end

    hash_accessors :payload, :build, :jobs, :owner, :repository, :request, :pull_request, :tag, :commit
    hash_accessors :repository, :slug
    hash_accessors :commit, :branch, :author_name, :committer_name
    hash_accessors :build, :state, :previous_state, :finished_at, pull_request?: :pull_request, external_id: :id

    attr_reader :generator

    def initialize(generator)
      @generator = generator
    end

    def state(state = nil)
      state ||= build[:state]
      state == 'persisted' ? 'queued' : state
    end

    def icon_url(state = nil)
      "#{Travis.config.http_host}/images/stroke-icons/#{ICON.fetch(state(state))}"
    end

    def icon(state = nil)
      "<img src='#{icon_url(state)}' height='11'>"
    end

    def payload
      generator.payload
    end

    def matrix?
      jobs.size > 1
    end

    def completed?
      status == 'completed'
    end

    def status
      @status ||= STATUS.fetch(state)
    end

    def conclusion
      CONCLUSION[state]
    end

    def language
      @language ||= begin
        language = build[:config].fetch(:language, DEFAULT_LANGUAGE)
        LANGUAGES.fetch(language.to_sym, language.capitalize)
      end
    end

    def template(*keys)
      @templates       ||= {}
      @templates[keys] ||= keys.inject(TEMPLATES) { |t,k| t.fetch(k) }.gsub(/^ +/, '').each_line.with_index.map do |line, index|
        line.gsub(/\{\{([^\}]+)\}\}/) { eval($1, binding, "template:#{keys.join(':')}", index+1) }
      end.join
    end

    def code(lang, source)
      "<pre lang='#{lang}'>\n#{source.strip.gsub('<', '&lt;').gsub('>', '&gt;')}\n</pre>"
    end

    def escape(content, matcher = ESCAPE_MATCHER)
      return if content.nil?
      content.gsub(matcher, "\\\\\\0")
    end

    def number(input)
      NUMBERS.fetch(input, input)
    end
  end
end
