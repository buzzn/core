def connect_to_dump
  # connect to the dump database
  ActiveRecord::Base.establish_connection Import.global('config.database_dump_url')
end

def connect_to_prod
  # change connection back
  ActiveRecord::Base.establish_connection Import.global('config.database_url')
end

def transfer_webforms
  connect_to_dump
  forms = []
  WebsiteForm.all.each do |form|
    forms.push(form.attributes)
  end
  connect_to_prod
  forms.each do |form|
    form.delete('id')
    WebsiteForm.create!(form)
  end
end

def transfer_displays
  connect_to_dump
  settings = Group::Localpool.pluck(:slug, :show_display_app)
  connect_to_prod
  settings.each do |setting|
    group = Group::Localpool.where(:slug => setting[0]).first
    unless group.nil?
      group.show_display_app = setting[1]
      group.save
    end
  end
end

def transfer_stats
  connect_to_dump
  begin
    Group::Localpool.first.fake_stats
  rescue ActiveModel::MissingAttributeError
    connect_to_prod
    return
  end
  settings = Group::Localpool.pluck(:slug, :fake_stats)
  connect_to_prod
  settings.each do |setting|
    group = Group::Localpool.where(:slug => setting[0]).first
    unless group.nil?
      group.fake_stats = setting[1]
      group.save
    end
  end
end
