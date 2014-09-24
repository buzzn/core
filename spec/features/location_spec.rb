require 'spec_helper'


feature 'Location' do

  before(:each)

  before(:all) do
    create(:idea)
    visit root_path
    click_link "Log In"
  end

  describe 'try to manage locations', :js do

    it 'will create new location' do
      click_link 'new'

    end


  end

end