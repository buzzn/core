namespace :docker do
  namespace :image do

    def image_name
      @_image_name ||= begin
        # Overwritten since the repo still has to be renamed to core.
        # Be careful when copy/pasting this file between console and admin app.
        # repo_name = `git remote get-url origin`.split("/").last.gsub(".git", '').chomp
        repo_name = 'core'
        OpenStruct.new(local: repo_name, public: "buzzn/#{repo_name}")
      end
    end

    desc "Builds an image of the current branch."
    task :build do
      filename = 'BUILD_INFO'
      sh 'echo "version: $(git log --pretty=format:%H -n1)" > ' + filename
      sh 'echo "timestamp: $(date)" >> ' + filename
      sh "docker build -t #{image_name.local} ."
    end

    desc "Builds an image of the current branch and push it to the registry at hub.docker.com."
    task push: :build do
      sh "docker tag #{image_name.local} #{image_name.public}"
      sh "docker push #{image_name.public}"
    end
  end
end
