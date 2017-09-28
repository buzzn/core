# Run the following commands in the CI shell process with:
# source script/ci/pipeline_1.sh

export RAILS_ENV=development
bundle exec rake db:drop db:create db:migrate db:structure:dump
bash -c 'if [ -z "$(git status --porcelain db)" ]; then exit 0; else git diff db| cat -; exit 1; fi'
bundle exec rake db:data
bundle exec rake banks:import
#bundle exec rake sep:import_pv_bhkw