module Travis::Addons::GithubCheckStatus::Output
  class PullRequest
    include Helpers

    def name
      'Pull Request'
    end

    def description
      "This is a [pull request build](https://docs.travis-ci.com/user/pull-requests/).\n\n" \
      "It is running a build against the merge commit, after merging [##{pull_request[:number]} #{escape pull_request[:title]}](#{pull_request_url}).\n" \
      "Any changes that have been made to the #{escape branch} branch before the build ran are also included."
    end

    def pull_request_url
      uri      = URI.parse(commit[:compare_url])
      parts    = uri.path.split("/", 4)[0..2] << "pull/#{pull_request[:number]}"
      uri.path = parts.join("/")
      uri.to_s
    end

    def sha
      request[:head_commit]
    end

    def head_ref
      pull_request[:head_ref]
    end
  end
end
