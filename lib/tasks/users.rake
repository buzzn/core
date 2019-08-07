namespace :users do

  desc 'List all users'
  task list: :environment do
    all_accounts = Account::Base.all
    print JSON.pretty_generate(all_accounts.collect { |x| { email: x.email } })
  end

  def read_from_stdin(attribute_name:, empty: false, secret: false)
    value = if secret
              STDIN.getpass(attribute_name + ': ')
            else
              print attribute_name + ': '
              STDIN.readline
            end
    if !empty && value.strip.empty?
      raise "#{attribute_name} cannot be empty"
    end
    value.strip
  end

  task create: :environment do
    require_relative '../../db/support/create_buzzn_operator'
    email = read_from_stdin(attribute_name: 'Email')
    first_name = read_from_stdin(attribute_name: 'First Name')
    last_name = read_from_stdin(attribute_name: 'Last Name')
    password = read_from_stdin(attribute_name: 'Password', secret: true)
    password_repeat = read_from_stdin(attribute_name: 'Password (Repeat)', secret: true)
    if password != password_repeat
      raise 'Passwords do not match'
    end
    create_buzzn_operator(
      first_name: first_name,
      last_name:  last_name,
      email:      email,
      password:   password
    )
  end

  task delete: :environment do
    email = read_from_stdin(attribute_name: 'Email')
    account = Account::Base.where(:email => email).first
    if account.nil?
      raise 'No such account'
    end
    account.destroy
    print 'Deleted'
  end

end
