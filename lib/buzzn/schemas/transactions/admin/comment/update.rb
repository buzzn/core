require_relative '../comment'

module Schemas::Transactions::Admin::Comment

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:content).filled(:str?, max_size?: 65536)
    optional(:author).filled(:str?, max_size?: 192)
  end

end
