class DeviceSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes  :id,
              :name,
              :manufacturer_name,
              :manufacturer_product_name,
              :manufacturer_product_serialnumber,
              :mode,
              :law,
              :category,
              :shop_link,
              :primary_energy,
              :watt_peak,
              :watt_hour_pa,
              :commissioning,
              :mobile,
              :big_tumb,
              :updateable, :deletable

  def big_tumb
    object.image.big_tumb.url
  end


  def abilities
    @user = current_user || User.new
    @device = Device.find(object.id)
    abilities = []
    abilities << 'update' if @user.can_update?(@device)
    abilities << 'delete' if @user.can_delete?(@device)
    return abilities
  end

  def updateable
    abilities.include? 'update'
  end

  def deletable
    abilities.include? 'delete'
  end



end
