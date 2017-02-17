class Contract::LocalpoolProcessing < Contract::BuzznSystems

  def self.new(*args)
    super
  end

  belongs_to :localpool, class_name: 'Group'

  validates :localpool, presence: true
  validates :first_master_uid, presence: true
  validates :second_master_uid, presence: false

end
