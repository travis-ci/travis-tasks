module Travis::Addons::GithubCheckStatus::Output
  class SingleJob
    include Helpers

    def description
      "This build only has a single job.\n" \
      "You can use jobs to [test against multiple versions](https://docs.travis-ci.com/user/customizing-the-build/#Build-Matrix) " \
      "of your runtime or dependencies, or to [speed up your build](https://docs.travis-ci.com/user/speeding-up-the-build/)."
    end
  end
end
