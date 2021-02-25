require 'rails_helper'

RSpec.describe 'Admin merchants index spec' do
  before :each do
    @merchant1, @merchant2, @merchant3 = create_list(:merchant, 3)
  end

  describe 'as an admin' do
    it 'shows name of each merchant in the system' do
      visit admin_merchants_path

      within('#all-merchants') do
        expect(page).to have_content(@merchant1.name)
        expect(page).to have_content(@merchant2.name)
        expect(page).to have_content(@merchant3.name)
      end
    end

    it 'names of merchants are links to their show page' do
      visit admin_merchants_path

      within('#all-merchants') do
        expect(page).to have_link(@merchant1.name)
        expect(page).to have_link(@merchant2.name)
        expect(page).to have_link(@merchant3.name)

        # Only testing one merchant
        click_link @merchant1.name
        expect(current_path).to eq admin_merchant_path(@merchant1)
      end
    end

    it 'shows button to enable/disable merchant next to their name' do
      visit admin_merchants_path

      within('#all-merchants') do
        expect(page).to have_button("disable-#{@merchant1.id}")
        expect(page).to have_button("disable-#{@merchant2.id}")
        expect(page).to have_button("disable-#{@merchant3.id}")

        click_button("disable-#{@merchant1.id}")
      end

      expect(current_path).to eq(admin_merchants_path)

      within('#all-merchants') do
        expect(page).to have_button("enable-#{@merchant1.id}")
        expect(page).to have_button("disable-#{@merchant2.id}")
        expect(page).to have_button("disable-#{@merchant3.id}")
      end
    end
  end
end
