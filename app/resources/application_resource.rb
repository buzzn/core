class ApplicationResource < JSONAPI::Resource


  def md_img
    @model.image.md.url
  end

  def big_tumb
    @model.image.big_tumb.url
  end


  def updateable
    abilities.include? 'update'
  end

  def deletable
    abilities.include? 'delete'
  end


private

  def abilities
    @user = context[:current_user] || User.new
    abilities = []
    abilities << 'update' if @user.can_update?(@model)
    abilities << 'delete' if @user.can_delete?(@model)
    return abilities
  end

end
