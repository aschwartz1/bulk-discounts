class Invoice < ApplicationRecord
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions
  belongs_to :customer

  enum status: [:cancelled, :completed, :in_progress]

  def created_at_view_format
    created_at.strftime('%A, %B %d, %Y')
  end

  def self.all_invoices_with_unshipped_items
    joins(:invoice_items)
    .where('invoice_items.status = ?', 1)
    .distinct(:id)
    .order(:created_at)
  end

  def customer_full_name
    customer.full_name
  end

  def total_revenue
    invoice_items.pluck(Arel.sql("sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue"))
  end

  def total_revenue_with_discounts
    invoice_items_with_discount_percent.sum do |invoice_item|
      # TODO this method kinda belongs in `invoice_item` but an invoice_item instance
      #   doesn't normally have the `percent_discount` column so it seems odd?
      # OR I'd need this method to be a class method on the InvoiceItem and call the class method here...
      #   Which option is better?
      invoice_item_revenue(invoice_item.quantity, invoice_item.unit_price, invoice_item.percent_discount)
    end
  end

  def invoice_item_revenue(quantity, unit_price, raw_discount)
    raw_discount = 0 if raw_discount.nil?
    percent_discount = raw_discount / 100.0
    tmp_revenue = (quantity * unit_price)

    return tmp_revenue - (tmp_revenue * percent_discount)
  end

  def invoice_items_with_discount_percent
    discount_percent_sql = Arel.sql(%{
      SELECT percent_discount
      FROM bulk_discounts
      WHERE items.merchant_id = bulk_discounts.merchant_id AND bulk_discounts.threshold <= invoice_items.quantity
      ORDER BY bulk_discounts.percent_discount DESC
      LIMIT 1
    }.squish)

    invoice_items
      .joins(:item)
      .select("invoice_items.*, (#{discount_percent_sql}) AS percent_discount")
  end
end
