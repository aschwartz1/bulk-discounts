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
    # Arel snippet used at recommendation of deprecation warnings thrown by rails when testing
    revenue = invoice_items.pluck(Arel.sql("sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")).first
    if revenue.nil?
      0
    else
      revenue
    end
  end

  def total_revenue_with_discounts
    total_revenue - total_discount
  end

  def total_discount
    discount_snippet = 'invoice_items.quantity * invoice_items.unit_price * (percent_discount / 100.0)'
    items_with_total_discount = invoice_items.joins(:bulk_discounts)
      .where('invoice_items.quantity >= bulk_discounts.threshold')
      .group('invoice_items.item_id')
      .select("invoice_items.item_id, MAX(#{discount_snippet}) AS total_discount").sum(&:total_discount)
  end
end
