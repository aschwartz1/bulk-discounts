require 'rails_helper'

RSpec.describe "As a Factory Bot" do
  it "can create dummy objects to use for testing" do
    merchant = create(:merchant)
    customer = create(:customer)
    invoice = create(:invoice)
    item = create(:item)
    invoice_item = create(:invoice_item)
    transaction = create(:transaction)
    bulk_discount = create(:bulk_discount)

    expect(invoice.class).to eq(Invoice)
    expect(merchant.class).to eq(Merchant)
    expect(customer.class).to eq(Customer)
    expect(item.class).to eq(Item)
    expect(invoice_item.class).to eq(InvoiceItem)
    expect(transaction.class).to eq(Transaction)
    expect(bulk_discount.class).to eq(BulkDiscount)
  end
end
