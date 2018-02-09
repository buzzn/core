namespace :deploy do

  module DeploymentSupport
    def create_and_push_tag(prefix)
      tag = "#{prefix}-#{Time.now.strftime('%Y-%m-%d-%H-%M')}"
      sh "git tag #{tag}"
      sh "git push --tags"
    end

    def current_local_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def deploy(env)
      url = "https://git.heroku.com/buzzn-core-#{env}.git"
      sh "git push #{url} #{current_local_branch}:master"
    end
  end

  include DeploymentSupport

  desc "Deploy to staging"
  task :staging do
    deploy(:staging)
  end

  desc "Deploy to production"
  task :production do
    if deploy(:production)
      create_and_push_tag(:production)
    end
  end
end
