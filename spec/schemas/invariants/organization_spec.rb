require 'buzzn/schemas/invariants/organization'
require_relative 'name_size_shared'

describe 'Schemas::Invariants::Organization' do

  entity(:organization) { create(:organization) }

  context 'name' do
    it_behaves_like 'invariants of name-size', :organization
  end

end
