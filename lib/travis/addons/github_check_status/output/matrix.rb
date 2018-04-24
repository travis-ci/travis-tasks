module Travis::Addons::GithubCheckStatus::Output
  class Matrix
    include Helpers

    def description
      [
        template(:matrix_description, stages? ? :with_stages : :without_stages),
        *stages.map { |stage, jobs| Stage.new(generator, stage, jobs).description }
      ].compact.map(&:rstrip).join("\n\n")
    end

    def stages
      @stages ||= jobs.group_by { |job| job[:stage] }.sort_by { |s,j| s ? s[:number] : 0 }.to_h
    end

    def stages?
      stages.size > 1
    end
  end
end
