class Group < ActiveRecord::Base
  resourcify
  acts_as_commentable
  include Authority::Abilities
  include CalcVirtualMeteringPoint
  include ChartFunctions

  before_destroy :destroy_content

  include PublicActivity::Model
  tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked  recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :finders]


  validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

  normalize_attribute :name, with: [:strip]

  mount_uploader :logo, PictureUploader
  #mount_uploader :image, PictureUploader
  mount_base64_uploader :image, PictureUploader

  has_many :contracts, dependent: :destroy
  has_one  :area
  has_many :metering_points

  has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users

  has_many :scores, as: :scoreable

  # validates :metering_points, presence: true

  after_save :validate_localpool

  normalize_attributes :description, :website

  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :readable_by_world, -> { where(readable: 'world') }


  def self.search(search)
    if search
      where('name ILIKE ? or slug ILIKE ?', "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def energy_producers
    MeteringPoint.by_group(self).outputs.collect(&:users).flatten
  end

  def energy_consumers
    MeteringPoint.by_group(self).inputs.collect(&:users).flatten
  end

  def member?(metering_point)
    self.metering_points.include?(metering_point) ? true : false
  end

  def involved
    (self.managers + MeteringPoint.by_group(self).collect(&:involved).flatten).uniq
  end

  def members
    (MeteringPoint.by_group(self).collect(&:members).flatten).uniq
  end

  def in_metering_points
    MeteringPoint.where(group: self).where(mode: 'in')
  end

  def out_metering_points
    MeteringPoint.where(group: self).where(mode: 'out')
  end


  def received_group_metering_point_requests
    GroupMeteringPointRequest.where(group: self).requests
  end

  def keywords
    %w(buzzn people power) << self.name
  end

  def self.readables
    %w{
      world
      community
      friends
      members
    }
  end

  def self.modes
    %w(localpool public_group)
  end

  def readable_by_members?
    self.readable == 'members'
  end

  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_community?
    self.readable == 'community'
  end

  def readable_by_world?
    self.readable == 'world'
  end

  def readable_icon
    if readable_by_friends?
      "user-plus"
    elsif readable_by_world?
      "globe"
    elsif readable_by_members?
      "key"
    elsif readable_by_community?
      "users"
    end
  end

  def self.readable_group_ids_by_user(user)
    group_ids = Group.all.readable_by_world.ids
    if user.nil?
      return group_ids
    else
      group_ids << Group.where(readable: 'community').collect(&:id)
      group_ids << Group.with_role(:manager, user).collect(&:id)
      group_ids << user.accessible_metering_points.collect(&:group).compact.collect(&:id)

      user.friends.each do |friend|
        if friend
          Group.where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
            group_ids << friend_group.id
          end
        end
      end
      return group_ids.compact.flatten.uniq
    end
  end

  def calculate_total_energy_data(data, operators, resolution)
    calculate_virtual_metering_point(data, operators, resolution)
  end

  def chart(resolution_format, containing_timestamp=nil)
    if containing_timestamp == nil
      containing_timestamp = Time.now.to_i * 1000
    end

    data_in = []
    data_out = []

    metering_points_in = self.metering_points.without_externals.where(mode: 'in')
    metering_points_out = self.metering_points.without_externals.where(mode: 'out')
    operators = []
    metering_points_in.each do |metering_point|
      data_in << metering_point.chart_data(resolution_format, containing_timestamp)
      operators << "+"
    end
    result_in = calculate_virtual_metering_point(data_in, operators, resolution_format)

    operators = []

    metering_points_out.each do |metering_point|
      data_out << metering_point.chart_data(resolution_format, containing_timestamp)
      operators << "+"
    end
    result_out = calculate_virtual_metering_point(data_out, operators, resolution_format)

    #TODO: Aus irgend einem Grund gibt es bei manchen Gruppen einen falschen Zeitstempel
    if resolution_format == 'month_to_days'
      i = 0
      while i < result_in.size do
        if Time.at(result_in[i][0]/1000).in_time_zone.hour != 0
          result_in.delete_at(i)
        end
        i+=1
      end
      i = 0
      while i < result_out.size do
        if Time.at(result_out[i][0]/1000).in_time_zone.hour != 0
          result_out.delete_at(i)
        end
        i+=1
      end
    end

    return [ { :name => I18n.t('total_consumption'), :data => result_in}, { :name => I18n.t('total_production'), :data => result_out} ]
  end


  def chart_without_discovergy(resolution_format, containing_timestamp=nil)
    metering_points_in_plus = []
    metering_points_in_minus = []
    metering_points_out_plus = []
    metering_points_out_minus = []
    self.metering_points.without_externals.each do |metering_point|
      if metering_point.virtual
        if metering_point.input?
          metering_point.formula_parts.where(operator: "+").collect(&:operand).each do |metering_point_plus|
            metering_points_in_plus << metering_point_plus.id
          end
          metering_point.formula_parts.where(operator: "-").collect(&:operand).each do |metering_point_minus|
            metering_points_in_minus << metering_point_minus.id
          end
        else
          metering_point.formula_parts.where(operator: "+").collect(&:operand).each do |metering_point_plus|
            metering_points_out_plus << metering_point_plus.id
          end
          metering_point.formula_parts.where(operator: "-").collect(&:operand).each do |metering_point_minus|
            metering_points_out_minus << metering_point_minus.id
          end
        end
      else
        if metering_point.input?
          metering_points_in_plus << metering_point.id
        else
          metering_points_out_plus << metering_point.id
        end
      end
    end

    if containing_timestamp == nil
      containing_timestamp = Time.now.to_i * 1000
    end

    data_in = []
    data_out = []
    operators = ["+", "-"]
    data_in << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, metering_points_in_plus, containing_timestamp), resolution_format, containing_timestamp)
    if metering_points_in_minus.any?
      data_in << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, metering_points_in_minus, containing_timestamp), resolution_format, containing_timestamp)
      result_in = calculate_virtual_metering_point(data_in, operators, resolution_format)
    else
      result_in = data_in[0]
    end
    data_out << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, metering_points_out_plus, containing_timestamp), resolution_format, containing_timestamp)
    if metering_points_out_minus.any?
      data_out << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, metering_points_out_minus, containing_timestamp), resolution_format, containing_timestamp)
      result_out = calculate_virtual_metering_point(data_out, operators, resolution_format)
    else
      result_out = data_out[0]
    end
    return [ { :name => I18n.t('total_consumption'), :data => result_in}, { :name => I18n.t('total_production'), :data => result_out} ]
  end

  def calculate_closeness
    Sidekiq::Client.push({
      'class' => CalculateGroupScoreClosenessWorker,
      'queue' => :default,
      'args' => [ self.id ]
    })
  end

  def set_score_interval(resolution_format, containing_timestamp)
    if resolution_format == 'year_to_minutes' || resolution_format == 'year'
      return ['year', Time.at(containing_timestamp).in_time_zone.beginning_of_year, Time.at(containing_timestamp).in_time_zone.end_of_year]
    elsif resolution_format == 'month_to_minutes' || resolution_format == 'month'
      return ['month', Time.at(containing_timestamp).in_time_zone.beginning_of_month, Time.at(containing_timestamp).in_time_zone.end_of_month]
    elsif resolution_format == 'day_to_minutes' || resolution_format == 'day'
      return ['day', Time.at(containing_timestamp).in_time_zone.beginning_of_day, Time.at(containing_timestamp).in_time_zone.end_of_day]
    end
  end

  def extrapolate_kwh_pa(kwh_ago, resolution_format, containing_timestamp)
    days_ago = 0
    if resolution_format == 'year'
      if Time.at(containing_timestamp).end_of_year < Time.now
        days_ago = 365
      else
        days_ago = ((Time.now - Time.now.beginning_of_year)/(3600*24.0)).to_i
      end
    elsif resolution_format == 'month'
      if Time.at(containing_timestamp).end_of_month < Time.now
        days_ago = Time.at(containing_timestamp).days_in_month
      else
        days_ago = Time.now.day
      end
    elsif resolution_format == 'day'
      if Time.at(containing_timestamp).end_of_day < Time.now
        days_ago = 1
      else
        days_ago = (Time.now - Time.now.beginning_of_day)/(3600*24.0)
      end
    end
    return kwh_ago / (days_ago*1.0) * 365
  end


  def self.update_cache
    Group.all.select(:id).each.each do |group|
      Sidekiq::Client.push({
       'class' => UpdateGroupChartCache,
       'queue' => :default,
       'args' => [ group.id, 'day_to_minutes']
      })
    end
  end

  def self.calculate_scores
    Group.all.select(:id).each.each do |group|
      # Sidekiq::Client.push({
      #  'class' => CalculateGroupScoreSufficiencyWorker,
      #  'queue' => :default,
      #  'args' => [ group.id, 'day', Time.now.to_i*1000]
      # })

      Sidekiq::Client.push({
       'class' => CalculateGroupScoreAutarchyWorker,
       'queue' => :default,
       'args' => [ group.id, 'day', (Time.now - 1.day).to_i*1000]
      })

      # Sidekiq::Client.push({
      #  'class' => CalculateGroupScoreFittingWorker,
      #  'queue' => :default,
      #  'args' => [ group.id, 'day', Time.now.to_i*1000]
      # })
    end
  end

  def bubbles_energy_data
    in_metering_point_energy_data = []
    out_metering_point_energy_data = []

    if self.metering_points.externals.any?
      # self.metering_points.externals.each do |external_metering_point| #TODO: enable for more than 1 external metering_point

      #   if external_metering_point.mode == 'in'
      #     data = external_metering_point.last_power_each
      #   else
      #     data = external_metering_point.last_power_each
      #   end
      #   data[:result].each do |reading|
      #     metering_point = self.metering_points.without_externals.joins(:meter).where("meters.manufacturer_product_serialnumber" => (reading[:meter_id]).to_i).first
      #     if metering_point.nil?
      #       next
      #     end
      #     metering_point_name = metering_point.decorate.name_with_users
      #     if metering_point.users.any?
      #       if metering_point.users.include?(requesting_user)
      #         own_metering_point = true
      #       else
      #         own_metering_point = false
      #       end
      #     else
      #       own_metering_point = false
      #     end
      #     readable = requesting_user.nil? ? false : metering_point.readable_by?(requesting_user)
      #     if !readable
      #       metering_point_name = "anonym"
      #     end
      #     if external_metering_point.mode == 'in'
      #       data_entry = {:metering_point_id => metering_point.id, :latest_power => reading[:power], :name => metering_point_name, :own_metering_point => own_metering_point, :readable => readable}
      #       in_metering_point_data.push(data_entry)
      #     else
      #       data_entry = {:metering_point_id => metering_point.id, :latest_power => reading[:power], :name => metering_point_name, :own_metering_point => own_metering_point, :readable => true}
      #       out_metering_point_data.push(data_entry)
      #     end
      #   end
      # end
    else
      self.metering_points.without_externals.each do |metering_point|
        energy_data_entry = []
        personal_data_entry = []

        latest_power = nil
        virtual = metering_point.virtual
        latest_power = metering_point.last_power

        energy_data_entry = {:metering_point_id => metering_point.id, :latest_power => (latest_power.nil? || latest_power[:power].nil?) ? 0 : latest_power[:power], :virtual => virtual}
        if metering_point.mode == "out"
          out_metering_point_energy_data.push(energy_data_entry)
        else
          in_metering_point_energy_data.push(energy_data_entry)
        end
      end
    end
    out_data = { :name => "Gesamterzeugung", :children => out_metering_point_energy_data}
    energy_data = {:in => in_metering_point_energy_data, :out => out_data}
    return energy_data
  end

  def bubbles_personal_data(requesting_user)
    out_metering_point_personal_data = []
    in_metering_point_personal_data = []
    self.metering_points.without_externals.each do |metering_point|
      metering_point_name = metering_point.decorate.name_with_users
      if metering_point.involved.any?
        if metering_point.involved.include?(requesting_user)
          own_metering_point = true
        else
          own_metering_point = false
        end
      else
        own_metering_point = false
      end
      readable = requesting_user.nil? ? false : metering_point.readable_by?(requesting_user)
      if !readable
        metering_point_name = "anonym"
      end
      personal_data_entry = {:metering_point_id => metering_point.id, :name => metering_point_name, :own_metering_point => own_metering_point, :readable => readable}
      if metering_point.mode == 'out'
        out_metering_point_personal_data.push(personal_data_entry)
      else
        in_metering_point_personal_data.push(personal_data_entry)
      end
    end
    personal_data = {:in => in_metering_point_personal_data, :out => out_metering_point_personal_data}
    return personal_data
  end

  def get_scores(resolution, containing_timestamp)
    if resolution.nil?
      resolution = "year_to_months"
    end
    if containing_timestamp.nil?
      containing_timestamp = Time.now.to_i * 1000
    end

    if resolution == 'day_to_minutes'
      sufficiency = self.scores.sufficiencies.dayly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.dayly.at(containing_timestamp).first
      fitting = self.scores.fittings.dayly.at(containing_timestamp).first
    elsif resolution == 'month_to_days'
      sufficiency = self.scores.sufficiencies.monthly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.monthly.at(containing_timestamp).first
      fitting = self.scores.fittings.monthly.at(containing_timestamp).first
    elsif resolution == 'year_to_months'
      sufficiency = self.scores.sufficiencies.yearly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.yearly.at(containing_timestamp).first
      fitting = self.scores.fittings.yearly.at(containing_timestamp).first
    end
    sufficiency.nil? ? sufficiency_value = -1 : sufficiency_value = sufficiency.value
    autarchy.nil? ? autarchy_value = -1 : autarchy_value = autarchy.value
    fitting.nil? ? fitting_value = -1 : fitting_value = fitting.value
    return { sufficiency: sufficiency_value, closeness: self.closeness, autarchy: autarchy_value, fitting: fitting_value }
  end


  private

    def destroy_content
      self.metering_points.each do |metering_point|
        metering_point.group = nil
        metering_point.save
        metering_point.meter.save if metering_point.meter
      end
      GroupMeteringPointRequest.where(group: self).each{|request| request.destroy}
      self.root_comments.each{|comment| comment.destroy}
    end

    def validate_localpool
      if self.mode == 'localpool'
        if self.contracts.metering_point_operators.empty?
          @contract = Contract.new(mode: 'metering_point_operator_contract', price_cents: 0, group: self, organization: Organization.find('buzzn-metering'), username: 'team@localpool.de', password: 'Zebulon_4711')
        else
          @contract = self.contracts.metering_point_operators.first
        end
        @contract.save
      else
        if self.contracts.any?
          self.contracts.each do |contract|
            contract.delete
            #contract.save
          end
        end
      end
    end






end
