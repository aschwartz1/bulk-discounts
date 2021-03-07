require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationhips' do
    it { should have_many :items }
    it { should have_many(:invoice_items).through(:items)}
    it { should have_many :bulk_discounts }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should define_enum_for(:status).with_values(disabled: 0, enabled: 1) }
  end

  describe 'class methods' do
    describe '::by_status' do
      it 'enabled' do
        disabled_merchant = create(:merchant)
        enabled_merchant = create(:merchant, status: Merchant.statuses[:enabled])

        expect(Merchant.by_status(:enabled)).to eq([enabled_merchant])
      end

      it 'disabled' do
        disabled_merchant = create(:merchant)
        enabled_merchant = create(:merchant, status: Merchant.statuses[:enabled])

        expect(Merchant.by_status(:disabled)).to eq([disabled_merchant])
      end

      it '<invalid>' do
        disabled_merchant = create(:merchant)
        enabled_merchant = create(:merchant, status: Merchant.statuses[:disabled])

        expect(Merchant.by_status(:nonexistent)).to eq([])
      end
    end

    describe '::top_five_by_revenue' do
      it 'shows top five merchants by total revenue earned on successful transactions' do
        setup_top_five_revenue
        expected_names = [@merchant_5.name, @merchant_4.name, @merchant_3.name, @merchant_2.name, @merchant_1.name]
        actual_names = Merchant.top_five_by_revenue.map(&:name)

        expect(actual_names).to eq(expected_names)
      end
    end
  end

  describe 'instance methods' do
    describe '#top_five_customers' do
      it 'finds the top five customers' do
        setup_merchant_and_customers
        expected = [@customer_1, @customer_5, @customer_4, @customer_3, @customer_2]

        expect(@merchant.top_five_customers).to eq(expected)
      end
    end

    describe '#invoice_items_ready' do
      it 'returns items for the merchant that need to be shipped' do
        setup_merchant_and_customers
        expect(@merchant.invoice_items_ready).to eq([@invoice_item_1])
        expect(@merchant.invoice_items_ready).not_to include(@invoice_item_2)
      end
    end

    describe '#total_revenue' do
      it 'calculates total revenue for a merchant' do
        merchant_7_with_history

        expect(@merchant_7.total_revenue).to eq(6)
      end

      it 'ignores failed transactions' do
        merchant_5_with_history

        expect(@merchant_5.total_revenue).to eq(50)
      end
    end

    describe '#top_selling_date' do
      it 'finds top revenue day by invoice date' do
        merchant_8_with_history

        expect(@merchant_8.best_day).to eq(sample_date)
      end

      it 'returns most recent day if there is a tie' do
        merchant_9_with_history

        expect(@merchant_9.best_day).to eq(sample_date)
      end

      it 'ignores failed transactions' do
        merchant_10_with_history

        expect(@merchant_10.best_day).to eq(sample_date)
      end
    end
  end

  def sample_date
    DateTime.new(2021, 01, 01)
  end

  def setup_merchant_and_customers
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

  def setup_top_five_revenue
    merchant_1_with_history
    merchant_2_with_history
    merchant_3_with_history
    merchant_4_with_history
    merchant_5_with_history
    merchant_6_with_history
    merchant_7_with_history
  end

  def merchant_1_with_history
    @merchant_1 = create(:merchant, name: 'Merchant 1')
    customer = create(:customer)
    item = @merchant_1.items.create!(name: 'Item', description: 'foo bar baz quux', unit_price: 10)
    invoice = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice.id, item_id: item.id, quantity: 1, unit_price: 10)
    Transaction.create!(invoice_id: invoice.id, result: Transaction.results[:success])
  end

  def merchant_2_with_history
    @merchant_2 = create(:merchant, name: 'Merchant 2')
    customer = create(:customer)
    item = @merchant_2.items.create!(name: 'Item', description: 'foo bar baz quux', unit_price: 10)
    invoice = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice.id, item_id: item.id, quantity: 1, unit_price: 20)
    Transaction.create!(invoice_id: invoice.id, result: Transaction.results[:success])
  end

  def merchant_3_with_history
    @merchant_3 = create(:merchant, name: 'Merchant 3')
    customer = create(:customer)
    item = @merchant_3.items.create!(name: 'Item', description: 'foo bar baz quux', unit_price: 20)
    invoice = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice.id, item_id: item.id, quantity: 1, unit_price: 30)
    Transaction.create!(invoice_id: invoice.id, result: Transaction.results[:success])
  end

  def merchant_4_with_history
    @merchant_4 = create(:merchant, name: 'Merchant 4')
    customer = create(:customer)
    item_1 = @merchant_4.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_4.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 1, unit_price: 40)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 40)
    # Note first transaction is failed
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:failed])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:success])
  end

  def merchant_5_with_history
    @merchant_5 = create(:merchant, name: 'Merchant 5')
    customer = create(:customer)
    item_1 = @merchant_5.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_5.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 1, unit_price: 50)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 50)
    # Note second transaction is failed
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:failed])
  end

  def merchant_6_with_history
    @merchant_6 = create(:merchant, name: 'Merchant 6')
    customer = create(:customer)
    item = @merchant_6.items.create!(name: 'Item', description: 'foo bar baz quux', unit_price: 10)
    invoice = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice.id, item_id: item.id, quantity: 1, unit_price: 1)
    Transaction.create!(invoice_id: invoice.id, result: Transaction.results[:success])
  end

  def merchant_7_with_history
    @merchant_7 = create(:merchant, name: 'Merchant 7')
    customer = create(:customer)
    item_1 = @merchant_7.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_7.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed])
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 1, unit_price: 3)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 3)
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:success])
  end

  def merchant_8_with_history
    # Merchant w/ best revenue day of `sample_date`
    @merchant_8 = create(:merchant, name: 'Merchant 8')
    customer = create(:customer)
    item_1 = @merchant_8.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_8.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: (sample_date + 1))
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: (sample_date + 1))
    invoice_3 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: sample_date)
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 2, unit_price: 10)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 20)
    InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_1.id, quantity: 2, unit_price: 50)
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_3.id, result: Transaction.results[:success])
  end

  def merchant_9_with_history
    # Merchant w/ tie for best revenue days
    @merchant_9 = create(:merchant, name: 'Merchant 9')
    customer = create(:customer)
    item_1 = @merchant_9.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_9.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: (sample_date))
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: (sample_date - 1))
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 2, unit_price: 10)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 20)
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:success])
  end

  def merchant_10_with_history
    # Merchant w/ failed transaction on what would've been their best revenue day if the transaction succeeded
    @merchant_10 = create(:merchant, name: 'Merchant 10')
    customer = create(:customer)
    item_1 = @merchant_10.items.create!(name: 'Item 1', description: 'foo bar baz quux', unit_price: 10)
    item_2 = @merchant_10.items.create!(name: 'Item 2', description: 'foo bar baz quux', unit_price: 20)
    invoice_1 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: sample_date)
    invoice_2 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: sample_date)
    invoice_3 = Invoice.create!(customer_id: customer.id, status: Invoice.statuses[:completed], created_at: (sample_date + 1))
    InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 1, unit_price: 10)
    InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 1, unit_price: 20)
    InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_1.id, quantity: 10, unit_price: 10)
    Transaction.create!(invoice_id: invoice_1.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_2.id, result: Transaction.results[:success])
    Transaction.create!(invoice_id: invoice_3.id, result: Transaction.results[:failed])
  end
end
