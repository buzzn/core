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
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'schule_logo_wogeno.jpg'))}
  image     { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'Wogeno_app.jpg')) }
end

Fabricator :localpool_sulz, from: :localpool do
  name        'Localpool Sulz'
  description { "Dies ist der Localpool Sulz in Perißenberg" }
end

Fabricator :localpool_sulz_with_registers_and_readings, from: :localpool_sulz do
  before_create do |localpool|
    meter = Fabricate(:easymeter_60300856)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1100*20, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 183900*20, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    register = meter.output_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1000*20, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 510200*20, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register

    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, label: Register::Base::GRID_CONSUMPTION_CORRECTED),
                                          Fabricate.build(:output_register, label: Register::Base::GRID_FEEDING_CORRECTED)])
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::ENERGY_QUANTITY_SUMMARIZED, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    register = meter.output_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::ENERGY_QUANTITY_SUMMARIZED, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register

    register = Fabricate(:easymeter_60009498).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1100, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 248000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register

    register = Fabricate(:easymeter_60404855).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 10770500, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register

    register = Fabricate(:easymeter_60404845).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 7060800, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
  end

  after_create do |localpool|
    Fabricate(:organization, mode: 'other', name: 'HaFi', address: Fabricate(:address))
    register = Fabricate(:easymeter_60404846).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 241100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_hafi, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404850).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 27489000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134118, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 864100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 858000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_hubv, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404851).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 24124000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 49350039, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 1892400, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1879000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_mape, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404853).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 23790, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4789917, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 10, 31), energy_milliwatt_hour: 191000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 11, 1), energy_milliwatt_hour: 191000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 808200, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 798000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_hafi2, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)
    Fabricate(:lptc_pewi, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404847).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 8024000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 5640077, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 456300, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 4529000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_musc, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404854).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 19442000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134120, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 809700, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 805000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_viwe, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404852).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 9597000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 5000705, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 1523000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1513000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:lptc_reho, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60327350).registers.first
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 9078000, reason: Reading::DEVICE_REMOVAL, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 16), energy_milliwatt_hour: 9341900, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 12), energy_milliwatt_hour: 9521100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 2, 28), energy_milliwatt_hour: 9801400, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: 4939588, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 2, 28), energy_milliwatt_hour: 733500, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 3, 1), energy_milliwatt_hour: 733500, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: register.meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    Fabricate(:osc_saba, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)
    Fabricate(:lptc_saba, signing_user: Fabricate(:user), register: register, customer: Fabricate(:user), contractor: Organization.where(name: 'HaFi').first)

    Fabricate(:lpc_sulz, localpool: self)
  end
end
