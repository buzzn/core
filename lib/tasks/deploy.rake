namespace :deploy do

  module Support
    def git_remotes
      `git remote -v | grep push`.split("\n").map { |line| line.split("\t").first.to_sym }
    end

    def ensure_git_remote_configured!(env)
      unless git_remotes.include?(env)
        puts "The remote git repository '#{env}' isn't configured. Add it with the following shell command, then try again."
        puts "> git remote add #{env} {git-repo-url}"
        exit
      end
    end

    def create_and_push_tag(prefix)
      tag = "#{prefix}-#{Time.now.strftime('%Y-%m-%d-%H-%M')}"
      sh "git tag #{tag}"
      sh "git push --tags"
    end

    def current_local_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def deploy(env)
      sh "git push #{env} #{current_local_branch}:master"
    end
  end

  include Support

  task :staging do
    ensure_git_remote_configured!(:staging)
    deploy(:staging)
  end

  task :production do
    ensure_git_remote_configured!(:production)
    if deploy(:production)
      create_and_push_tag(:production)
    end
  end
end
