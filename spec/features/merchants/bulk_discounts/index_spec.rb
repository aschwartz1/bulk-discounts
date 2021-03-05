require 'rails_helper'

RSpec.describe 'Merchant bulk discount index page' do
  before :each do
    @merchant = create(:merchant)
    @discount_1 = create(:bulk_discount, merchant: @merchant)
    @discount_2 = create(:bulk_discount, merchant: @merchant)
  end

  describe 'as a merchant' do
    it 'shows list of all my discounts with their info' do
      visit merchant_bulk_discounts_path(@merchant)

      within('#discounts') do
        expect(page.all('.discount').size).to eq(2)

        within("#discount-#{@discount_1.id}") do
          expect(page).to have_content(@discount_1.name)
          expect(page).to have_content(@discount_1.threshold)
          expect(page).to have_content(@discount_1.percent_discount)
        end

        within("#discount-#{@discount_2.id}") do
          expect(page).to have_content(@discount_2.name)
          expect(page).to have_content(@discount_2.threshold)
          expect(page).to have_content(@discount_2.percent_discount)
        end
      end
    end

    it "names of discounts are links to that discount's show page" do
      visit merchant_bulk_discounts_path(@merchant)

      within('#discounts') do
        within("#discount-#{@discount_1.id}") do
          expect(page).to have_link(@discount_1.name)
          click_link(@discount_1.name)
          expect(current_path).to eq(merchant_bulk_discount_path(id: @discount_1.id, merchant_id: @merchant.id))
        end

        visit merchant_bulk_discounts_path(@merchant)

        within("#discount-#{@discount_2.id}") do
          expect(page).to have_link(@discount_2.name)
          click_link(@discount_2.name)
          expect(current_path).to eq(merchant_bulk_discount_path(id: @discount_2.id, merchant_id: @merchant.id))
        end
      end
    end
  end
end
