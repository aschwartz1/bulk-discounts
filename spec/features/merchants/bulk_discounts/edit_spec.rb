require 'rails_helper'

RSpec.describe 'Edit merchant bulk discount page' do
  before :each do
    @merchant = create(:merchant)
    @discount = create(:bulk_discount, merchant: @merchant)
  end

  describe 'as a merchant' do
    it 'shows prepopulated form to edit a discount' do
      visit edit_merchant_bulk_discount_path(id: @discount.id, merchant_id: @merchant.id)

      within('#form') do
        expect(page.find('#bulk_discount_name').value).to eq(@discount.name)
        expect(page.find('#bulk_discount_threshold').value).to eq(@discount.threshold.to_s)
        expect(page.find('#bulk_discount_percent_discount').value).to eq(@discount.percent_discount.to_s)
      end
    end

    it 'can save new info' do
      visit edit_merchant_bulk_discount_path(id: @discount.id, merchant_id: @merchant.id)

      within('#form') do
        fill_in('bulk_discount_name', with: 'ASDF Discount')
        fill_in('bulk_discount_threshold', with: '6')
        fill_in('bulk_discount_percent_discount', with: '20')
        click_button('commit')
      end

      expect(current_path).to eq(merchant_bulk_discount_path(id: @discount.id, merchant_id: @merchant.id))
      expect(page).to have_content('ASDF Discount')
      expect(page).to have_content('6')
      expect(page).to have_content('20')
    end

    it 'shows flash message if save fails' do
      visit edit_merchant_bulk_discount_path(id: @discount.id, merchant_id: @merchant.id)

      within('#form') do
        fill_in('bulk_discount_name', with: '')
        click_button('commit')
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(id: @discount.id, merchant_id: @merchant.id))
      expect(page).to have_selector('.flash-message')
    end
  end
end
