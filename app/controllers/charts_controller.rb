class ChartsController < WebsocketRails::BaseController

  def initialize_session
    # perform application setup here
  end

  def rsvp
    broadcast_message :new_rsvp, "clicked at " + Time.now.to_s
  end
end