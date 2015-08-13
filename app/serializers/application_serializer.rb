class ApplicationSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope


  def md_img
    object.image.md.url
  end

  def big_tumb
    object.image.big_tumb.url
  end


  def updateable
    abilities.include? 'update'
  end

  def deletable
    abilities.include? 'delete'
  end


private

  def abilities
    @user = current_user || User.new
    abilities = []
    abilities << 'update' if @user.can_update?(object)
    abilities << 'delete' if @user.can_delete?(object)
    return abilities
  end

end