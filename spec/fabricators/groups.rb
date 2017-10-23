['localpool', 'tribe'].each do |klass_type|
  klass = "Group::#{klass_type.camelize}".constantize
  Fabricator klass_type, class_name: klass do
    name        { FFaker::Company.name[0..39] }
    description { FFaker::Lorem.paragraphs.join('-') }
    created_at  { (rand*10).days.ago }
    type        { "Group::#{klass_type.camelize}" }
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
    _comment2        = Fabricate(:comment, comment_params)
  }
end


Fabricator :tribe_hof_butenland, from: :tribe do
  name  'Hof Butenland'
  logo  { File.new(Rails.root.join('spec/fixture_files', 'groups', 'hof_butenland', 'logo.jpg')) }
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
  logo        File.new(Rails.root.join('spec/fixture_files', 'groups', 'wagnis4', 'logo.png'))
  image       File.new(Rails.root.join('spec/fixture_files', 'groups', 'wagnis4', 'image.png'))
  after_create do |localpool|
    Fabricate(:mpoc_buzzn_metering, localpool: localpool)
  end
end


Fabricator :localpool_forstenried, from: :localpool do
  name        'Mehrgenerationenplatz Forstenried'
  website     'http://www.energie.wogeno.de/'
  description { "Dies ist der Localpool des Mehrgenerationenplatzes Forstenried der Freien Waldorfschule München Südwest und Wogeno München eG." }
  logo      { File.new(Rails.root.join('spec/fixture_files', 'groups', 'forstenried', 'schule_logo_wogeno.jpg'))}
  image     { File.new(Rails.root.join('spec/fixture_files', 'groups', 'forstenried', 'Wogeno_app.jpg')) }
end

Fabricator :localpool_sulz, from: :localpool do
  name        'Localpool Sulz'
  description { "Dies ist der Localpool Sulz in Preißenberg" }
end

Fabricator :localpool_sulz_with_registers_and_readings, from: :localpool_sulz do
  before_create do |localpool|
    meter = Fabricate(:easymeter_60300856)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 1100000*20, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 183900000*20, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    register = meter.output_register
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 1000000*20, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 510200000*20, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register

    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, label: Register::Base::GRID_CONSUMPTION_CORRECTED),
                                          Fabricate.build(:output_register, label: Register::Base::GRID_FEEDING_CORRECTED)])
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    register = meter.output_register
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register

    register = Fabricate(:easymeter_60009498).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 1100000*20, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 248000000*20, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register

    register = Fabricate(:easymeter_60404855).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 10770500000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register

    register = Fabricate(:easymeter_60404845).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 7060800000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
  end

  after_create do |localpool|
    Fabricate(:organization, name: 'HaFi').update(address: Fabricate(:address))
    register = Fabricate(:easymeter_60404846).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 13855000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 241100000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_hafi, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404850).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 27489000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 864100000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 858000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_hubv, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404851).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 24124000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 1892400000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 1879000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_mape, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404853).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 23790000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 10, 31), value: 191000000, reason: Reading::Single::CONTRACT_CHANGE, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::POWER_GIVER, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 11, 1), value: 191000000, reason: Reading::Single::CONTRACT_CHANGE, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::POWER_GIVER, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 808200000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 798000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_hafi2, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)
    Fabricate(:lptc_pewi, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404847).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 8024000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 456300000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 4529000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_musc, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404854).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 19442000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 809700000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 805000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_viwe, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60404852).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 9597000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 1), value: 1523000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 1513000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:lptc_reho, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    register = Fabricate(:easymeter_60327350).registers.first
    Fabricate(:single_reading, register: register, date: Date.new(2016, 8, 4), value: 9078000000, reason: Reading::Single::DEVICE_REMOVAL, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 16), value: 9341900000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 12), value: 9521100000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 2, 28), value: 9801400000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::POWER_GIVER, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 2, 28), value: 733500000, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::POWER_GIVER, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 3, 1), value: 733500000, reason: Reading::Single::CONTRACT_CHANGE, quality: Reading::Single::READ_OUT, source: Reading::Single::MANUAL, read_by: Reading::Single::POWER_GIVER, status: Reading::Single::Z86)
    localpool.registers << register
    Fabricate(:osc_saba, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)
    Fabricate(:lptc_saba, signing_user: FFaker::Name.name, register: register, customer: Fabricate(:person), contractor: Organization.where(name: 'HaFi').first)

    Fabricate(:lpc_sulz, localpool: self, contractor: Organization.buzzn || Fabricate(:buzzn), customer: Organization.where(name: 'HaFi').first)

    # TODO use Fabricate(:price_sulz) - as it breaks the lcp_report when using
    #      Fabricate(:price_sulz)
    Fabricate(:price,
              localpool: self,
              name: 'Standard',

              begin_date: Date.new(2016, 8, 4),
              energyprice_cents_per_kilowatt_hour: 23.8, # assume all money-data is without taxes!
              baseprice_cents_per_month: 500)
    localpool.update(address: Fabricate(:address))

    Fabricate(:osc_sulz, signing_user: FFaker::Name.name, register: self.registers.grid_consumption_corrected.first, customer: Organization.where(name: 'HaFi').first, localpool: self)
  end
end
