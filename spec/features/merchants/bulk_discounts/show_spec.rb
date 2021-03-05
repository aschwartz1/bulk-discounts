require 'rails_helper'

RSpec.describe 'Merchant bulk_discounts index' do
  describe 'as a merchant' do
    it 'shows all my discounts with info' do
      merchant = create(:merchant)
      discount = create(:bulk_discount, merchant: merchant)
      visit merchant_bulk_discount_path(merchant_id: merchant.id, id: discount.id)

      within('#info') do
        expect(page).to have_content(discount.name)
        expect(page).to have_content(discount.threshold)
        expect(page).to have_content(discount.percent_discount)
      end
    end
  end
end
