require_relative '../permission'

WebsiteFormResource::Permission = Buzzn::Permission.new(WebsiteFormResource) do

  define_group(:admins, Role::BUZZN_OPERATOR)
  define_group(:all, Role::ANONYMOUS)

  website_forms do
    create :all
    retrieve :admins
  end

end
