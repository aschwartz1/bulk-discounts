require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationhips' do
    it { should belong_to :merchant }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:threshold) }
    it { should validate_numericality_of(:threshold) }
    it { should validate_presence_of(:percent_discount) }
    it { should validate_numericality_of(:percent_discount) }
  end

  describe 'class methods' do
    describe '::for' do
      it 'returns bulk discounts for merchant' do
        merchant = create(:merchant)
        expected = create_list(:bulk_discount, 3, merchant: merchant)

        expect(BulkDiscount.for(merchant.id)).to eq(expected)
      end

      it 'returns an empty array if no discounts exist for merchant' do
        merchant = create(:merchant)
        expect(BulkDiscount.for(merchant.id)).to eq([])
      end
    end

    describe '::by_merchant_order_discount_threshold_desc' do
      it "returns correctly sorted list of a merchant's discounts" do
        merchant = create(:merchant)
        discount_1 = create(:bulk_discount, threshold: 8, percent_discount: 30, merchant_id: merchant.id)
        discount_2 = create(:bulk_discount, threshold: 6, percent_discount: 20, merchant_id: merchant.id)
        discount_3 = create(:bulk_discount, threshold: 4, percent_discount: 10, merchant_id: merchant.id)

        expected_order = [discount_1, discount_2, discount_3]
        expect(BulkDiscount.by_merchant_order_discount_threshold_desc(merchant.id)).to eq(expected_order)
      end

      it 'returns correct order when unreachable discount percent exists' do
        merchant = create(:merchant)
        discount_1 = create(:bulk_discount, threshold: 8, percent_discount: 30, merchant_id: merchant.id)
        discount_2 = create(:bulk_discount, threshold: 6, percent_discount: 10, merchant_id: merchant.id)
        discount_3 = create(:bulk_discount, threshold: 4, percent_discount: 20, merchant_id: merchant.id)

        expected_order = [discount_1, discount_3, discount_2]
        expect(BulkDiscount.by_merchant_order_discount_threshold_desc(merchant.id)).to eq(expected_order)
      end

      it 'returns empty array when no discounts exist' do
        merchant = create(:merchant)
        expect(BulkDiscount.by_merchant_order_discount_threshold_desc(merchant.id)).to eq([])
      end
    end

    describe '::for_merchant_quantity' do
      it 'returns 0 if there are no discounts' do
        merchant = create(:merchant)
        expect(BulkDiscount.for_merchant_quantity(merchant.id, 5)).to eq(0)
      end

      it 'sorts correctly' do
        merchant = create(:merchant)
        discount_1 = create(:bulk_discount, threshold: 10, percent_discount: 10, merchant_id: merchant.id)
        discount_2 = create(:bulk_discount, threshold: 5, percent_discount: 50, merchant_id: merchant.id)

        expect(BulkDiscount.for_merchant_quantity(merchant.id, 10)).to eq(0.5)
      end
    end
  end
end
