require_relative 'base'

class Register::Substitute < Register::Base

  belongs_to :meter, class_name: 'Meter::Virtual', foreign_key: :meter_id

  def data_source
    Buzzn::Discovergy::DataSource::NAME
  end

end
