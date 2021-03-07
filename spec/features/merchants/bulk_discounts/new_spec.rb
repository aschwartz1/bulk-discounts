require 'rails_helper'

RSpec.describe 'New Merchant bulk discount page' do
  before :each do
    @merchant = create(:merchant)
  end

  describe 'as a merchant' do
    it 'shows form to enter info for a new discount' do
      visit new_merchant_bulk_discount_path(@merchant)

      within('#form') do
        fill_in('bulk_discount_name', with: 'ASDF Discount')
        fill_in('bulk_discount_threshold', with: '6')
        fill_in('bulk_discount_percent_discount', with: '20')
        click_button('commit')
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
      expect(page).to have_content('ASDF Discount')
    end

    it 'shows flash message if save fails' do
      visit new_merchant_bulk_discount_path(@merchant)

      within('#form') do
        click_button('commit')
      end

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
      expect(page).to have_selector('.flash-message')
    end
  end
end
