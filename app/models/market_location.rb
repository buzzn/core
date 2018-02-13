class MarketLocation < ActiveRecord::Base

  belongs_to :group, class_name: 'Group::Base'
  has_many :contracts

  # Fully implementing 1:n, i.e. that a market location has many current and past registers is a future story.
  # I'm already setting things up 1:n on the DB and association level, hopefully that'll make implementation
  # easier later on.
  has_many :registers, class_name: 'Register::Base'
  private :registers

  def register
    registers.first
  end

  def register=(new_register)
    self.registers = new_register ? [new_register] : []
  end

end
