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
  end
end
