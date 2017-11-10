# Run the following commands in the CI shell process with:
# source script/ci/pipeline_2.sh

export RAILS_ENV=test
bundle exec rake db:structure:load
bundle exec brakeman -z
bundle exec rspec --tag ~slow:false
bash -c 'if [ -z "$(git status --porcelain app lib)" ]; then exit 0; else git diff app lib | cat -; exit 1; fi'
#RAILS_ENV=development bundle exec rake db:create db:migrate slp:import_h0
