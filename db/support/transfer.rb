def transfer_webforms
  # connect to the dump database
  ActiveRecord::Base.establish_connection Import.global('config.database_dump_url')
  forms = []
  WebsiteForm.all.each do |form|
    forms.push(form.attributes)
  end
  # change connection back
  ActiveRecord::Base.establish_connection Import.global('config.database_url')
  forms.each do |form|
    WebsiteForm.create!(form)
  end
end
