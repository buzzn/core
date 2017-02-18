# coding: utf-8

['localpool', 'tribe'].each do |type|
  klass = "Group::#{type.camelize}".constantize
  Fabricator type, class_name: klass do
    name        { FFaker::Company.name[0..39] }
    description { FFaker::Lorem.paragraphs.join('-') }
    readable    'world'
    created_at  { (rand*10).days.ago }
  end
end


Fabricator :tribe_readable_by_world, from: :tribe do
  readable    'world'
end

Fabricator :tribe_readable_by_community, from: :tribe do
  readable    'community'
end

Fabricator :tribe_readable_by_friends, from: :tribe do
  readable    'friends'
end

Fabricator :tribe_readable_by_members, from: :tribe do
  readable    'members'
end

Fabricator :tribe_with_two_comments_readable_by_world, from: :tribe do
  after_create { |group|
    comment_params  = {
       commentable_id:     group.id,
       commentable_type:   'Group::Base',
       parent_id:          '',
     }
    comment         = Fabricate(:comment, comment_params)
    comment_params[:parent_id] = comment.id
    comment2        = Fabricate(:comment, comment_params)
  }
end

Fabricator :tribe_with_members_readable_by_world, from: :tribe do
  transient members: 1
  registers do |attrs|
    register  = Fabricate(:input_meter).input_register
    register.update(readable: :world)
    attrs[:members].times do
      user          = Fabricate(:user)
      user.add_role(:member, register)
    end
    [register]
  end
end


Fabricator :tribe_hof_butenland, from: :tribe do
  name  'Hof Butenland'
  logo  { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'hof_butenland', 'logo.jpg')) }
end


Fabricator :localpool_hopf, from: :localpool do
  name 'Hopf'
  after_create do |localpool|
    Fabricate(:mpoc_buzzn_metering, localpool: localpool)
  end
end

Fabricator :localpool_home_of_the_brave, from: :localpool do
  name        'Home of the Brave'
  after_create do |localpool|
    Fabricate(:mpoc_buzzn_metering, localpool: localpool)
  end
end

Fabricator :tribe_karins_pv_strom, from: :tribe do
  name        'Karins PV Strom'
  description "Diese Gruppe ist offen für alle, die gerne meinen selbstgemachten PV-Strom von meiner Scheune beziehen möchten."
end

Fabricator :localpool_wagnis4, from: :localpool do
  name        'Wagnis 4'
  website     'http://www.wagnis.org/wagnis/wohnprojekte/wagnis-4.html'
  description "Dies ist der Localpool von Wagnis 4."
  logo        File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'logo.png'))
  image       File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'image.png'))
  after_create do |localpool|
    Fabricate(:mpoc_buzzn_metering, localpool: localpool)
  end
end


Fabricator :localpool_forstenried, from: :localpool do
  name        'Mehrgenerationenplatz Forstenried'
  website     'http://www.energie.wogeno.de/'
  description { "Dies ist der Localpool des Mehrgenerationenplatzes Forstenried der Freien Waldorfschule München Südwest und Wogeno München eG." }
  # contracts { [Fabricate(:mpoc_buzzn_metering)] }
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'schule_logo_wogeno.jpg'))}
  image     { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'Wogeno_app.jpg')) }
  after_create do |localpool|
    Fabricate(:mpoc_buzzn_metering, localpool: localpool)
  end
end
