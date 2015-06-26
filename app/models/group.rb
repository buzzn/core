class Group < ActiveRecord::Base
  resourcify
  acts_as_commentable
  include Authority::Abilities
  include CalcVirtualMeteringPoint

  before_destroy :release_metering_points

  include PublicActivity::Model
  tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
  #tracked  recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  def slug_candidates
    [
      :slug,
      :slug_name
    ]
  end

  validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

  normalize_attribute :name, with: [:strip]

  mount_uploader :logo, PictureUploader
  mount_uploader :image, PictureUploader

  has_many :contracts, dependent: :destroy
  has_one  :area
  has_many :metering_points

  validates :metering_points, presence: true

  has_many :group_users
  has_many :users, :through => :group_users

  normalize_attributes :description, :website

  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }




  def managers
    User.with_role :manager, self
  end

  def member?(metering_point)
    self.metering_points.include?(metering_point) ? true : false
  end

  def received_group_metering_point_requests
    GroupMeteringPointRequest.where(group: self)
  end

  def keywords
    %w(buzzn people power) << self.name
  end

  def calculate_total_energy_data(data, operators, resolution)
    calculate_virtual_metering_point(data, operators, resolution)
  end


  def chart(resolution_format, containing_timestamp=nil)
    metering_points_in_plus = []
    metering_points_in_minus = []
    metering_points_out_plus = []
    metering_points_out_minus = []
    self.metering_points.each do |metering_point|
      if metering_point.virtual
        metering_point.formula_parts.where(operator: "+").collect(&:operand).each do |metering_point_plus|
          if metering_point_plus.input?
            metering_points_in_plus << metering_point_plus.id
          else
            metering_points_out_plus << metering_point_plus.id
          end
        end
        metering_point.formula_parts.where(operator: "-").collect(&:operand).each do |metering_point_minus|
          if metering_point_minus.input?
            metering_points_in_minus << metering_point_minus.id
          else
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



  def get_sufficiency(resolution_format, containing_timestamp)
    count_sn_in_group = 0
    metering_points.each do |metering_point|
      count_sn_in_group += metering_point.users.count if metering_point.input?
      #TODO: enable virtual metering_points
    end
    result_in = self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, self.metering_points.where(mode: "in").collect(&:id), containing_timestamp), resolution_format, containing_timestamp).flatten
    if result_in.empty?
      return 0
    end
    if count_sn_in_group != 0
      sufficiency = extrapolate_kwh_pa(result_in[1], resolution_format, containing_timestamp)/count_sn_in_group
    else
      sufficiency = nil
    end

    if sufficiency < 500
      return 5
    elsif sufficiency < 900
      return 4
    elsif sufficiency < 1500
      return 3
    elsif sufficiency < 2300
      return 2
    elsif sufficiency >= 2300
      return 1
    else
      return 0
    end
  end

  def calculate_closeness
    addresses_out = self.metering_points.where(mode: 'out').collect(&:address).compact
    addresses_in = self.metering_points.where(mode: 'in').collect(&:address).compact
    sum_distances = 0
    addresses_in.each do |address_in|
      addresses_out.each do |address_out|
        sum_distances += address_in.distance_to(address_out)
      end
    end
    if addresses_out.count * addresses_in.count != 0
      average_distance = sum_distances / (addresses_out.count * addresses_in.count)
      if average_distance < 10
        self.closeness = 5
      elsif average_distance < 20
        self.closeness = 4
      elsif average_distance < 50
        self.closeness = 3
      elsif average_distance < 200
        self.closeness = 2
      elsif average_distance >= 200
        self.closeness = 1
      else
        self.closeness = 0
      end
    else
      self.closeness = nil
    end
    self.save
  end

  def get_autarchy(resolution_format, containing_timestamp)
    if resolution_format == :year
      resolution_format = :year_to_minutes
    elsif resolution_format == :month
      resolution_format = :month_to_minutes
    elsif resolution_format == :day
      resolution_format = :day_to_minutes
    end
    chart_data = self.chart(resolution_format, containing_timestamp)
    data_in = chart_data[0][:data]
    data_out = chart_data[1][:data]
    i = 0
    sum_variation = 0
    count_variation = 0
    while i < data_in.count do
      if data_in[i][1] > data_out[i][1]
        sum_variation += (data_in[i][1] - data_out[i][1])/(data_in[i][1] * 1.0)
        count_variation += 1
      #else
      #  sum_variation += (data_out[i][1] - data_in[i][1])/(data_out[i][1] * 1.0)
      end
      i+=1
    end

    if count_variation != 0
      autarchy = sum_variation / count_variation
    else
      return 5
    end

    if autarchy < 0.1
      return 5
    elsif autarchy < 0.2
      return 4
    elsif autarchy < 0.5
      return 3
    elsif autarchy < 0.75
      return 2
    elsif autarchy >= 0.75
      return 1
    else
      return 0
    end
  end



  def extrapolate_pa_with_timestamps(value, timestamp1, timestamp2)
    seconds_diff = Time.at(timestamp2) - Time.at(timestamp1)
    puts seconds_diff
    return value / (seconds_diff * 1.0) * 365 * 24 * 3600
  end



  def extrapolate_kwh_pa(kwh_ago, resolution_format, containing_timestamp)
    days_ago = 0
    if resolution_format == :year
      if Time.at(containing_timestamp).end_of_year < Time.now
        days_ago = 365
      else
        days_ago = ((Time.now - Time.now.beginning_of_year)/(3600*24)).to_i
      end
    elsif resolution_format == :month
      if Time.at(containing_timestamp).end_of_month < Time.now
        days_ago = Time.at(containing_timestamp).days_in_month
      else
        days_ago = Time.now.day
      end
    elsif resolution_format == :day
      if Time.at(containing_timestamp).end_of_day < Time.now
        days_ago = 1
      else
        days_ago = (Time.now - Time.now.beginning_of_day)/(3600*24)
      end
    end
    return kwh_ago / (days_ago*1.0) * 365
  end


  def self.update_chart_cache
    Group.all.select(:id).each.each do |group|
      Sidekiq::Client.push({
       'class' => UpdateGroupChartCache,
       'queue' => :default,
       'args' => [ group.id, 'day_to_minutes']
      })
    end
  end


  private

    def release_metering_points
      self.metering_points.each do |metering_point|
        metering_point.group = nil
        metering_point.save
      end
    end

    def slug_name
      SecureRandom.uuid
    end


end