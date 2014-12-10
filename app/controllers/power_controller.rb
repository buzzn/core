class PowerController < WebsocketRails::BaseController
  def initialize_session

  end

  def push_value(metering_point_id, value)
    broadcast_message :new_ticker_value, "called at " + Time.now.to_s
  end
end