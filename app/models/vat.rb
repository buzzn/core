require 'date'

class Vat < ActiveRecord::Base
  self.table_name = :vats

  # Returns the current vat tariff, which is valid today.
  def self.current
    where("begin_date < ?", Date.today).order("begin_date DESC").first!
  end
end