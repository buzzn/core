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


  validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

  normalize_attribute :name, with: [:strip]

  mount_uploader :logo, PictureUploader
  #mount_uploader :image, PictureUploader
  mount_base64_uploader :image, PictureUploader

  has_many :contracts, dependent: :destroy
  has_one  :area
  has_many :metering_points

  has_many :scores, as: :scoreable

  # validates :metering_points, presence: true

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
    metering_points_in = self.metering_points.where(mode: 'in')
    metering_points_out = self.metering_points.where(mode: 'out')

    if containing_timestamp == nil
      containing_timestamp = Time.now.to_i * 1000
    end

    data_in = []
    data_out = []
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
    return [ { :name => I18n.t('total_consumption'), :data => result_in}, { :name => I18n.t('total_production'), :data => result_out} ]
  end


  def chart_without_discovergy(resolution_format, containing_timestamp=nil)
    metering_points_in_plus = []
    metering_points_in_minus = []
    metering_points_out_plus = []
    metering_points_out_minus = []
    self.metering_points.each do |metering_point|
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
      return ['year', Time.at(containing_timestamp).beginning_of_year.utc, Time.at(containing_timestamp).end_of_year.utc]
    elsif resolution_format == 'month_to_minutes' || resolution_format == 'month'
      return ['month', Time.at(containing_timestamp).beginning_of_month.utc, Time.at(containing_timestamp).end_of_month.utc]
    elsif resolution_format == 'day_to_minutes' || resolution_format == 'day'
      return ['day', Time.at(containing_timestamp).beginning_of_day.utc, Time.at(containing_timestamp).end_of_day.utc]
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
      Sidekiq::Client.push({
       'class' => CalculateGroupScoreSufficiencyWorker,
       'queue' => :default,
       'args' => [ group.id, 'day', Time.now.to_i*1000]
      })

      Sidekiq::Client.push({
       'class' => CalculateGroupScoreAutarchyWorker,
       'queue' => :default,
       'args' => [ group.id, 'day', Time.now.to_i*1000]
      })

      Sidekiq::Client.push({
       'class' => CalculateGroupScoreFittingWorker,
       'queue' => :default,
       'args' => [ group.id, 'day', Time.now.to_i*1000]
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



end