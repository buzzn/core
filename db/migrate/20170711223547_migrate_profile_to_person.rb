class MigrateProfileToPerson < ActiveRecord::Migration
  def up
    User.reset_column_information
    Profile.all.each do |profile|
      prefix = case profile.gender
               when 'm'
                 'M'
               when 'f'
                 'F'
               end
      user = profile.user
      title = case profile.title
              when 'Dr. habil.'
                'Dr.'
              else
                profile.title
              end
      person = Person.create(title: title,
                             prefix: prefix,
                             first_name: profile.first_name,
                             last_name: profile.last_name,
                             email: profile.user.email,
                             phone: profile.phone,
                             preferred_language: 'de',
                             sales_tax_number: profile.user.sales_tax_number,
                             tax_rate: profile.user.tax_rate,
                             tax_number: profile.user.tax_number,
                             retailer: profile.user.retailer,
                             provider_permission: profile.user.provider_permission,
                             subject_to_tax: profile.user.subject_to_tax,
                             mandate_reference: profile.user.mandate_reference,
                             creditor_id: profile.user.creditor_id)
      user.person = person
      if address = user.address
        address.addressable = person
        address.save
      end
      unless user.save
        warn "user without address #{user.id}"
        def user.valid?(*args); true; end
        user.save
      end
      user.add_role(:self, person)
    end
    change_column_null :users, :person_id, true
  end
end
