namespace :application do
  desc 'Initializes the application using example data'
  task init: %i(db:reset db:seed:setup_data db:seed:buzzn_operator config:set zip_to_price:set_config zip_to_price:import)

end
