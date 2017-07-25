ActiveRecord::Base.connection.tables.each do |table|
  next if table.match(/\Aschema_migrations\Z/)
  klass = table.singularize.camelize.safe_constantize
  if klass
    print klass.name
    if klass.class == Module
      klass = klass.const_get 'Base'
    end
    if klass
      print " has #{klass.count} records and "
      broken = klass.all.select { |e| ! e.valid? }.count rescue 0
      puts " #{broken} are broken"
    end
  end
end
