class TestAdminLocalpoolRoda < BaseRoda
  route do |r|
    r.on('test') { r.run Admin::LocalpoolRoda }
    r.run Me::Roda
  end
end
