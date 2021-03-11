require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationhips' do
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many :transactions }
    it { should belong_to :customer }
  end

  describe 'instance methods' do
    describe '#status_view_format' do
      it "cleans up statuses so they are capitalize and have no symbols on view" do
        invoice_a = create(:invoice, status: Invoice.statuses[:cancelled])
        invoice_b = create(:invoice, status: Invoice.statuses[:completed])
        invoice_c = create(:invoice, status: Invoice.statuses[:in_progress])

        expect(invoice_a.status_view_format).to eq("Cancelled")
        expect(invoice_b.status_view_format).to eq("Completed")
        expect(invoice_c.status_view_format).to eq("In Progress")
      end
    end

    describe '#created_at_view_format' do
      it "cleans up statuses so they are capitalize and have no symbols on view" do
        invoice_a = create(:invoice, created_at: Time.new(2021, 2, 24))

        expect(invoice_a.created_at_view_format).to eq("Wednesday, February 24, 2021")
      end
    end

    describe '#customer_full_name' do
      it 'returns customers full name' do
        setup_little_esty_shop
        expect(@invoice_1.customer_full_name).to eq(@customer_1.full_name)
      end
    end

    describe '#total_revenue' do
      it 'returns total revenue from a specific invoice' do
        setup_little_esty_shop
        expect('%.2f' % @invoice_1.total_revenue).to eq('30.00')
      end

      it 'returns 0 if there are no invoice_items' do
        invoice = create(:invoice, status: :in_progress)
        expect(invoice.total_revenue).to eq(0)
      end
    end

    describe '#total_discount' do
      it 'returns total revenue from a specific invoice' do
        setup_discount_example_2
        expect(@invoice.total_discount).to eq(5)
      end

      it 'returns 0 if there are no invoice_items' do
        invoice = create(:invoice, status: :in_progress)
        expect(invoice.total_discount).to eq(0)
      end
    end

    describe '#total_revenue_with_discounts' do
      it 'no valid discounts' do
        setup_discount_example_1
        expect(@invoice.total_revenue_with_discounts).to eq(15)
      end

      it '1 valid discount, applying to 1 of 2 invoice_items' do
        # Total Revenue => 10
        setup_discount_example_2
        expect(@invoice.total_revenue_with_discounts).to eq(10)
      end

      it '2 valid discounts, each appying to an invoice_item' do
        # Total Revenue => 17.6
        setup_discount_example_3
        expect(@invoice.total_revenue_with_discounts).to eq(17.6)
      end

      it 'unreachable discount, and lower quantity discount applies to invoice_item well above threshold' do
        # Total Revenue => 15
        setup_discount_example_4
        expect(@invoice.total_revenue_with_discounts).to eq(15)
      end

      it 'multiple merchants on invoice, only one merchant has discounts' do
        # Total Revenue => 35.1
        setup_discount_example_5
        expect(@invoice.total_revenue_with_discounts).to eq(35.1)
      end
    end
  end

  describe 'class methods' do
    describe '::all_invoices_with_unshipped_items' do
      it 'returns all invoices with unshipped items' do
        setup_little_esty_shop
        expect(Invoice.all_invoices_with_unshipped_items).to eq([@invoice_1, @invoice_21])
      end
    end
  end

  def setup_little_esty_shop
    @merchant = create(:merchant)

    @item_1 = create(:item, merchant_id: @merchant.id)
    @item_2 = create(:item, merchant_id: @merchant.id)
    @item_3 = create(:item, merchant_id: @merchant.id)

    @customer_1 = create(:customer, first_name: "Ace")
    @customer_2 = create(:customer, first_name: "Eli")
    @customer_3 = create(:customer)
    #customer_1 related vars
    @invoice_1 = create(:invoice, customer_id: @customer_1.id)
    @invoice_2 = create(:invoice, customer_id: @customer_1.id)
    @invoice_3 = create(:invoice, customer_id: @customer_1.id)
    @transaction_1 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_1.id)
    @transaction_2 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_2.id)
    @ii_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, status: InvoiceItem.statuses[:packaged], quantity: 5, unit_price: 1.00)
    @ii_2 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_2.id, status: InvoiceItem.statuses[:shipped], quantity: 5, unit_price: 2.00)
    @ii_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, status: InvoiceItem.statuses[:shipped], quantity: 5, unit_price: 5.00)
    #customer_2 related vars
    @invoice_4 = create(:invoice, customer_id: @customer_2.id)
    @invoice_5 = create(:invoice, customer_id: @customer_2.id)
    @invoice_21 = create(:invoice, customer_id: @customer_2.id)
    @invoice_22 = create(:invoice, customer_id: @customer_2.id)
    @transaction_21 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_21.id)
    @transaction_22 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_22.id)
    @ii_21 = create(:invoice_item, invoice_id: @invoice_21.id, status: InvoiceItem.statuses[:packaged])
    #customer_3 related vars
    @invoice_31 = create(:invoice, customer_id: @customer_3.id)
    @invoice_32 = create(:invoice, customer_id: @customer_3.id)
    @transaction_31 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_31.id)
    @transaction_32 = create(:transaction, result: Transaction.results[:success], invoice_id: @invoice_32.id)
    @ii_31 = create(:invoice_item, invoice_id: @invoice_31.id, status: InvoiceItem.statuses[:shipped])
  end

  def setup_discount_example_1
    @customer = create(:customer)
    @merchant = create(:merchant)
    @item_1 = create(:item, merchant_id: @merchant.id)
    @item_2 = create(:item, merchant_id: @merchant.id)
    @invoice = create(:invoice, customer_id: @customer.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 5, unit_price: 2.00)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_2.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 5, unit_price: 1.00)

    @discount = create(:bulk_discount, threshold: 10, percent_discount: 20, merchant_id: @merchant.id)

    # Result => no discounts applied
    # Total Revenue => 15
  end

  def setup_discount_example_2
    @customer = create(:customer)
    @merchant = create(:merchant)
    @item_1 = create(:item, merchant_id: @merchant.id)
    @item_2 = create(:item, merchant_id: @merchant.id)
    @invoice = create(:invoice, customer_id: @customer.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 10, unit_price: 1.00)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_2.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 5, unit_price: 1.00)

    @discount = create(:bulk_discount, threshold: 10, percent_discount: 50, merchant_id: @merchant.id)

    # Result => item_1 discounted 50%
    # Total Revenue => 10
  end

  def setup_discount_example_3
    @customer = create(:customer)
    @merchant = create(:merchant)
    @item_1 = create(:item, merchant_id: @merchant.id)
    @item_2 = create(:item, merchant_id: @merchant.id)
    @invoice = create(:invoice, customer_id: @customer.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 12, unit_price: 1.00)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_2.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 16, unit_price: 1.00)

    @discount_1 = create(:bulk_discount, threshold: 10, percent_discount: 20, merchant_id: @merchant.id)
    @discount_2 = create(:bulk_discount, threshold: 15, percent_discount: 50, merchant_id: @merchant.id)

    # Result => item_1 discounted 20%, item_2 discounted 50%
    # Total Revenue => 17.6
  end

  def setup_discount_example_4
    @customer = create(:customer)
    @merchant = create(:merchant)
    @item_1 = create(:item, merchant_id: @merchant.id)
    @item_2 = create(:item, merchant_id: @merchant.id)
    @invoice = create(:invoice, customer_id: @customer.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 12, unit_price: 1.00)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_2.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 18, unit_price: 1.00)

    @discount_1 = create(:bulk_discount, threshold: 10, percent_discount: 50, merchant_id: @merchant.id)
    @discount_2 = create(:bulk_discount, threshold: 15, percent_discount: 15, merchant_id: @merchant.id)

    # Result => item_1 discounted 50%, item_2 discounted 50% (discount_2 can never be applied)
    # Total Revenue => 15
  end

  def setup_discount_example_5
    @customer = create(:customer)
    @merchant_a = create(:merchant)
    @merchant_b = create(:merchant)
    @item_a1 = create(:item, merchant_id: @merchant_a.id)
    @item_a2 = create(:item, merchant_id: @merchant_a.id)
    @item_b1 = create(:item, merchant_id: @merchant_b.id)
    @invoice = create(:invoice, customer_id: @customer.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_a1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 12, unit_price: 1.00)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_a2.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 15, unit_price: 1.00)
    @invoice_item_3 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item_b1.id,
                            status: InvoiceItem.statuses[:shipped], quantity: 15, unit_price: 1.00)

    @discount_1 = create(:bulk_discount, threshold: 10, percent_discount: 20, merchant_id: @merchant_a.id)
    @discount_2 = create(:bulk_discount, threshold: 15, percent_discount: 30, merchant_id: @merchant_a.id)
    # Merchant B has no discounts

    # Result => item_a1 discounted 20%, item_a2 discounted 30%, item_b1 not discounted
    # Total Revenue => 35.1
  end
end
