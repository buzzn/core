module Register
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base

    attributes  :direction,
                :name,
                :readable

    has_one  :address
    has_one  :meter

    # API methods for the endpoints

    collections :scores

    def comments
      Comment.where(
           commentable_type: Register::Base,
           commentable_id: object.id
      ).readable_by(@current_user)
    end
  end
end
