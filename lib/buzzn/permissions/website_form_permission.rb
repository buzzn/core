require_relative '../permission'

WebsiteFormResource::Permission = Buzzn::Permission.new(WebsiteFormResource) do

  define_group(:none)
  define_group(:admins, Role::BUZZN_OPERATOR)
  define_group(:all, Role::ANONYMOUS)

  create :all
  retrieve :admins
  update :admins
  delete :none

end
