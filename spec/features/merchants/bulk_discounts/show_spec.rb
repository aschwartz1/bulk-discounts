require 'rails_helper'

RSpec.describe 'Merchant bulk_discounts index' do
  before :each do
    @merchant = create(:merchant)
    @discount = create(:bulk_discount, merchant: @merchant)
  end

  describe 'as a merchant' do
    it 'shows all my discounts with info' do
      visit merchant_bulk_discount_path(@merchant, @discount)

      within('#info') do
        expect(page).to have_content(@discount.name)
        expect(page).to have_content(@discount.threshold)
        expect(page).to have_content(@discount.percent_discount)
      end
    end

    it 'shows a link to edit the discount' do
      visit merchant_bulk_discount_path(@merchant, @discount)

      within('#info') do
        click_link('Edit')
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @discount))
    end
  end
end
