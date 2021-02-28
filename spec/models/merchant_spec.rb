require 'rails_helper'

RSpec.describe Merchant, type: :model do
  before :each do
    setup_data
  end

  describe 'relationhips' do
    it { should have_many :items }
    it { should have_many(:invoice_items).through(:items)}
  end

  describe 'validations' do
    it { should define_enum_for(:status).with_values(disabled: 0, enabled: 1) }
  end

  describe 'class methods' do
    it '::by_status - enabled' do
      disabled_merchant = create(:merchant)
      enabled_merchant = create(:merchant, status: Merchant.statuses[:enabled])

      expect(Merchant.by_status(:enabled)).to eq([enabled_merchant])
    end

    it '::by_status - disabled' do
      disabled_merchant = create(:merchant)
      enabled_merchant = create(:merchant, status: Merchant.statuses[:enabled])

      expect(Merchant.by_status(:disabled)).to eq([@merchant, disabled_merchant])
    end

    it '::by_status - <invalid>' do
      disabled_merchant = create(:merchant)
      enabled_merchant = create(:merchant, status: Merchant.statuses[:disabled])

      expect(Merchant.by_status(:nonexistent)).to eq([])
    end
  end

  describe 'instance methods' do
    it 'finds the top five customers' do
      expected = [@customer_1, @customer_5, @customer_4, @customer_3, @customer_2]

      expect(@merchant.top_five_customers).to eq(expected)
    end

    it 'returns items for the merchant that need to be shipped' do
      expect(@merchant.invoice_items_ready).to eq([@invoice_item_1])
      expect(@merchant.invoice_items_ready).not_to include(@invoice_item_2)
    end

    it 'returns the invoice date for an item ready to ship' do
      expect(@merchant.item_invoice_date(@invoice_1.id)).to eq(sample_date.strftime('%A, %B %d, %Y'))
    end

    it 'returns the top five items for a merchant in terms of total_revenue' do
      expect(@merchant.top_five_items).to eq([@item])
    end

    it 'returns total revenue for a merchants top five items' do
      expect(@merchant.top_five_items.first.total_revenue.to_f.round(2)).to eq(375.0)
    end
  end

  def sample_date
    DateTime.new(2021, 01, 01)
  end

  def setup_data
    @merchant = create(:merchant)

    @item = create(:item, merchant_id: @merchant.id)
    @item2 = create(:item, merchant_id: @merchant.id)
    @item3 = create(:item, merchant_id: @merchant.id)
    @item4 = create(:item, merchant_id: @merchant.id)
    @item5 = create(:item, merchant_id: @merchant.id)
    @item6 = create(:item, merchant_id: @merchant.id)

    @customer_1 = create(:customer, first_name: "Ace")
    @invoice_1 = create(:invoice, customer_id: @customer_1.id, status: :completed, created_at: sample_date)
    @invoice_2 = create(:invoice, customer_id: @customer_1.id, created_at: sample_date)
    @invoice_3 = create(:invoice, customer_id: @customer_1.id, created_at: sample_date)
    @invoice_4 = create(:invoice, customer_id: @customer_1.id, created_at: sample_date)
    @invoice_5 = create(:invoice, customer_id: @customer_1.id, created_at: sample_date)
    @invoice_6 = create(:invoice, customer_id: @customer_1.id, created_at: sample_date)

    @invoice_item_1 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_1.id, status: :pending, quantity: 5, unit_price: 5)
    @invoice_item_2 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_2.id, quantity: 5, unit_price: 5)
    @invoice_item_3 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_3.id, quantity: 5, unit_price: 5)
    @invoice_item_4 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_4.id, quantity: 5, unit_price: 5)
    @invoice_item_5 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_5.id, quantity: 5, unit_price: 5)
    @invoice_item_6 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_6.id, status: :shipped, quantity: 5, unit_price: 5)

    @transaction_1 = create(:transaction, result: 1, invoice_id: @invoice_1.id)
    @transaction_2 = create(:transaction, result: 1, invoice_id: @invoice_2.id)
    @transaction_3 = create(:transaction, result: 1, invoice_id: @invoice_3.id)
    @transaction_4 = create(:transaction, result: 1, invoice_id: @invoice_4.id)
    @transaction_5 = create(:transaction, result: 1, invoice_id: @invoice_5.id)

    @customer_2 = create(:customer, first_name: "Eli")
    @invoice_21 = create(:invoice, customer_id: @customer_2.id, created_at: sample_date)
    @invoice_22 = create(:invoice, customer_id: @customer_2.id, created_at: sample_date)
    @invoice_23 = create(:invoice, customer_id: @customer_2.id, created_at: sample_date)
    @invoice_24 = create(:invoice, customer_id: @customer_2.id, created_at: sample_date)
    @invoice_25 = create(:invoice, customer_id: @customer_2.id, created_at: sample_date)

    @invoice_item_21 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_21.id, quantity: 5, unit_price: 5)
    @invoice_item_22 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_22.id, quantity: 5, unit_price: 5)
    @invoice_item_23 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_23.id, quantity: 5, unit_price: 5)
    @invoice_item_24 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_24.id, quantity: 5, unit_price: 5)
    @invoice_item_25 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_25.id, quantity: 5, unit_price: 5)

    @transaction_21 = create(:transaction, result: 0, invoice_id: @invoice_21.id)
    @transaction_22 = create(:transaction, result: 0, invoice_id: @invoice_22.id)
    @transaction_23 = create(:transaction, result: 0, invoice_id: @invoice_23.id)
    @transaction_24 = create(:transaction, result: 1, invoice_id: @invoice_24.id)
    @transaction_25 = create(:transaction, result: 0, invoice_id: @invoice_25.id)

    @customer_3 = create(:customer, first_name: "Danny")
    @invoice_31 = create(:invoice, customer_id: @customer_3.id, created_at: sample_date)
    @invoice_32 = create(:invoice, customer_id: @customer_3.id, created_at: sample_date)
    @invoice_33 = create(:invoice, customer_id: @customer_3.id, created_at: sample_date)
    @invoice_34 = create(:invoice, customer_id: @customer_3.id, created_at: sample_date)
    @invoice_35 = create(:invoice, customer_id: @customer_3.id, created_at: sample_date)

    @invoice_item_31 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_31.id, quantity: 5, unit_price: 5)
    @invoice_item_32 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_32.id, quantity: 5, unit_price: 5)
    @invoice_item_33 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_33.id, quantity: 5, unit_price: 5)
    @invoice_item_34 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_34.id, quantity: 5, unit_price: 5)
    @invoice_item_35 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_35.id, quantity: 5, unit_price: 5)

    @transaction_31 = create(:transaction, result: 0, invoice_id: @invoice_31.id)
    @transaction_32 = create(:transaction, result: 1, invoice_id: @invoice_32.id)
    @transaction_33 = create(:transaction, result: 1, invoice_id: @invoice_33.id)
    @transaction_34 = create(:transaction, result: 0, invoice_id: @invoice_34.id)
    @transaction_35 = create(:transaction, result: 0, invoice_id: @invoice_35.id)

    @customer_4 = create(:customer, first_name: "Cate")
    @invoice_41 = create(:invoice, customer_id: @customer_4.id, created_at: sample_date)
    @invoice_42 = create(:invoice, customer_id: @customer_4.id, created_at: sample_date)
    @invoice_43 = create(:invoice, customer_id: @customer_4.id, created_at: sample_date)
    @invoice_44 = create(:invoice, customer_id: @customer_4.id, created_at: sample_date)
    @invoice_45 = create(:invoice, customer_id: @customer_4.id, created_at: sample_date)

    @invoice_item_41 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_41.id, quantity: 5, unit_price: 5)
    @invoice_item_42 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_42.id, quantity: 5, unit_price: 5)
    @invoice_item_43 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_43.id, quantity: 5, unit_price: 5)
    @invoice_item_44 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_44.id, quantity: 5, unit_price: 5)
    @invoice_item_45 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_45.id, quantity: 5, unit_price: 5)

    @transaction_41 = create(:transaction, result: 1, invoice_id: @invoice_41.id)
    @transaction_42 = create(:transaction, result: 1, invoice_id: @invoice_42.id)
    @transaction_43 = create(:transaction, result: 1, invoice_id: @invoice_43.id)
    @transaction_44 = create(:transaction, result: 0, invoice_id: @invoice_44.id)
    @transaction_45 = create(:transaction, result: 0, invoice_id: @invoice_45.id)

    @customer_5 = create(:customer, first_name: "Bob")
    @invoice_51 = create(:invoice, customer_id: @customer_5.id, created_at: sample_date)
    @invoice_52 = create(:invoice, customer_id: @customer_5.id, created_at: sample_date)
    @invoice_53 = create(:invoice, customer_id: @customer_5.id, created_at: sample_date)
    @invoice_54 = create(:invoice, customer_id: @customer_5.id, created_at: sample_date)
    @invoice_55 = create(:invoice, customer_id: @customer_5.id, created_at: sample_date)

    @invoice_item_51 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_51.id, quantity: 5, unit_price: 5)
    @invoice_item_52 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_52.id, quantity: 5, unit_price: 5)
    @invoice_item_53 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_53.id, quantity: 5, unit_price: 5)
    @invoice_item_54 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_54.id, quantity: 5, unit_price: 5)
    @invoice_item_55 = create(:invoice_item, item_id: @item.id, invoice_id: @invoice_55.id, quantity: 5, unit_price: 5)

    @transaction_51 = create(:transaction, result: 1, invoice_id: @invoice_51.id)
    @transaction_52 = create(:transaction, result: 1, invoice_id: @invoice_52.id)
    @transaction_53 = create(:transaction, result: 1, invoice_id: @invoice_53.id)
    @transaction_54 = create(:transaction, result: 1, invoice_id: @invoice_54.id)
    @transaction_55 = create(:transaction, result: 0, invoice_id: @invoice_55.id)

    @customer_6 = create(:customer)
    @customer_7 = create(:customer)
    @customer_8 = create(:customer)
    @customer_9 = create(:customer)
    @customer_10 = create(:customer)
  end
end
