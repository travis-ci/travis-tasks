TASK_PAYLOAD = {
  "owner" => {
    "id"=>1,
    "type"=>"User",
    "login"=>"login",
    "vcs_type"=>"GithubUser"
  },
  "repository" => {
    "id"=>1,
    "github_id"=>549743,
    "vcs_id"=>"549743",
    "vcs_type"=>"GithubRepository",
    "key"=>"-----BEGIN PUBLIC KEY-----",
    "slug"=>"svenfuchs/minimal",
    "vcs_slug"=>"svenfuchs/minimal",
    "name"=>"minimal",
    "owner_name"=>"svenfuchs",
    "owner_email"=>"svenfuchs@artweb-design.de",
    "owner_avatar_url"=>nil,
    "url"=>"https://github.com/svenfuchs/minimal"
  },
  "request" => {
    "token"=>"token",
    "base_commit"=>"base-commit",
    "head_commit"=>"head-commit"
  },
  "pull_request" => {
    "number"=>1,
    "title"=>"title"
  },
  "tag" => {
    "name"=>"v1.0.0"
  },
  "commit" => {
    "id"=>1,
    "sha"=>"62aae5f70ceee39123ef",
    "branch"=>"master",
    "message"=>"the commit message",
    "committed_at"=>"2014-04-03T09:22:05Z",
    "author_name"=>"Sven Fuchs",
    "author_email"=>"svenfuchs@artweb-design.de",
    "committer_name"=>"Sven Fuchs",
    "committer_email"=>"svenfuchs@artweb-design.de",
    "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop"
  },
  "build" => {
    "id"=>1,
    "repository_id"=>1,
    "commit_id"=>1,
    "number"=>2,
    "pull_request"=>false,
    "config" => {
      "rvm"=>["1.8.7", "1.9.2"]
    },
    "state"=>"passed",
    "previous_state"=>"passed",
    "started_at"=>"2014-04-03T10:21:05Z",
    "finished_at"=>"2014-04-03T10:22:05Z",
    "duration"=>60,
    "job_ids"=>[1, 2],
    "type"=>"push"
  },
  "jobs"=>[{
    "id"=>1,
    "number"=>"2.1",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.8.7"
    },
    "allow_failure"=>false
  }, {
    "id"=> 2,
    "number"=>"2.2",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.9.2"
    },
    "allow_failure"=>false
  }]
}

TASK_PAYLOAD_PULL_REQUEST = {
  "owner" => {
    "id"=>1,
    "type"=>"User",
    "login"=>"login",
    "vcs_type"=>"GithubUser"
  },
  "repository" => {
    "id"=>1,
    "key"=>"-----BEGIN PUBLIC KEY-----",
    "slug"=>"svenfuchs/minimal",
    "vcs_slug"=>"svenfuchs/minimal",
    "name"=>"minimal",
    "owner_name"=>"svenfuchs",
    "owner_email"=>"svenfuchs@artweb-design.de",
    "owner_avatar_url"=>nil,
    "url"=>"https://github.com/svenfuchs/minimal"
  },
  "request" => {
    "token"=>"token",
    "head_commit"=>"head-commit"
  },
  "pull_request" => {
    "number"=>1,
    "title"=>"title",
    "head_ref"=>"svenfuchs-patch-1",
  },
  "tag" => {
    "name"=>"v1.0.0"
  },
  "commit" => {
    "id"=>1,
    "sha"=>"62aae5f70ceee39123ef",
    "branch"=>"master",
    "message"=>"the commit message",
    "committed_at"=>"2014-04-03T09:22:05Z",
    "author_name"=>"Sven Fuchs",
    "author_email"=>"svenfuchs@artweb-design.de",
    "committer_name"=>"Sven Fuchs",
    "committer_email"=>"svenfuchs@artweb-design.de",
    "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop"
  },
  "build" => {
    "id"=>1,
    "repository_id"=>1,
    "commit_id"=>1,
    "number"=>2,
    "pull_request"=>true,
    "config" => {"rvm"=>"1.8.7"},
    "state"=>"passed",
    "previous_state"=>"failed",
    "started_at"=>"2014-04-03T10:21:05Z",
    "finished_at"=>"2014-04-03T10:22:05Z",
    "duration"=>60,
    "job_ids"=>[1],
    "type"=>"pull_request"
  },
  "jobs"=>[{
    "id"=>1,
    "number"=>"2.1",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.8.7"
    },
    "allow_failure"=>false
  }]
}

TASK_PAYLOAD_WITH_STAGES = TASK_PAYLOAD.merge({
  "jobs"=>[{
    "id"=>1,
    "number"=>"2.1",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.8.7"
    },
    "stage"=>{
      "number" => 1,
      "name"   => "Test",
      "state"  => "passed"
    },
    "allow_failure"=>false
  }, {
    "id"=> 2,
    "number"=>"2.2",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.9.2"
    },
    "stage"=>{
      "number" => 2,
      "name"   => "Deploy",
      "state"  => "passed"
    },
    "allow_failure"=>false
  }]
})

TASK_PAYLOAD_WITH_ENVS = TASK_PAYLOAD.merge({
  "jobs"=>[{
    "id"=>1,
    "number"=>"2.1",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.8.7",
      "env" => ["[secure]"]
    },
    "allow_failure"=>false
  }, {
    "id"=> 2,
    "number"=>"2.2",
    "state"=>"passed",
    "config" => {
      "rvm"=>"1.9.2",
      "env" => ["x=y"]
    },
    "allow_failure"=>false
  }]
})
