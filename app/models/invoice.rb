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
    # TODO this is using ruby, but should be reworked to leverage the db?
    invoice_items.sum(&:revenue_including_discounts)
  end

  def invoice_item_revenue(invoice_item_quantity, invoice_item_price, percent_discount)
    tmp_revenue = (invoice_item_quantity * invoice_item_price)

    if percent_discount.nil?
      tmp_revenue
    else
      tmp_revenue - (tmp_revenue * (percent_discount / 100))
    end
  end
end
