module API
  module V1
    class Registers < Grape::API
      include API::V1::Defaults
      resource :registers do

        params do
          requires :id, type: String
          requires :duration, type: String, values: %w(year month day hour)
          optional :timestamp, type: Time
        end
        get ":id/charts" do
          register = Register::Base.guarded_retrieve(current_user, permitted_params)
          interval = Buzzn::Interval.create(params[:duration], params[:timestamp])
          result = Buzzn::Application.config.charts.for_register(register, interval)

          # cache-control headers
          etag(Digest::SHA256.base64digest(result.to_json))
          expires((result.expires_at - Time.current.to_f).to_i,
                  current_user ? :private : :public)
          last_modified(Time.at(result.last_timestamp)) 

          result
        end

        params do
          requires :id, type: String
        end
        get ":id/ticker" do
          register = Register::BaseResource.retrieve(current_user,
                                                     permitted_params)
          result = Buzzn::Application.config.current_power.for_register(register)

          # cache-control headers
          etag(Digest::SHA256.base64digest(result.to_json))
          last_modified(Time.at(result.timestamp))
          expires((result.expires_at - Time.current.to_f).to_i,
                  current_user ? :private : :public)

          result
        end
      end
    end
  end
end
