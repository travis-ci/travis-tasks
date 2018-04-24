module Travis::Addons::GithubCheckStatus::Output
  TEMPLATES = {
    name: 'Travis CI − {{build_info.name}}',

    summary: {
      changed:   'The build **[{{state}}]({{details_url}})** on Travis CI. This is a change from the previous build, which **{{previous_state}}**.',
      unchanged: 'The build **[{{state}}]({{details_url}})** on Travis CI, just like the previous build.'
    },

    matrix_description: {
      without_stages: 'This build has **{{number jobs.size}} jobs**, running in parallel.',
      with_stages:    'This build has **{{number jobs.size}} jobs**, running in **{{number stages.size}} sequential stages**.'
    },

    stage_description: <<-MARKDOWN,
      ### Stage {{stage[:number]}}: {{stage[:name]}}
      This stage **{{stage[:state]}}**.
    MARKDOWN

    text: <<-MARKDOWN
      {{build_info.description}}

      ## Jobs and Stages
      {{job_info.description}}
    MARKDOWN
  }
end
