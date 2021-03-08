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

  def total_revenue_with_discount

  end

  def foo_total_revenue_with_discount
    # slim_invoice_items = invoice_items.select(:id, :quantity, :unit_price)
    # discounts = BulkDiscount.all_discount_threshold_desc

    # total_revenue = 0
    # slim_invoice_items.each do |invoice_item|
    #   # Calc revenue
    #   tmp_revenue = invoice_item.quantity * invoice_item.unit_price

    #   # Find if a discount applies
    #   discount_percent = 0
    #   discounts.each do |discount|
    #     if discount.threshold <= invoice_item.quantity
    #       discount_percent = discount.percent_discount
    #       break
    #     else
    #       next
    #     end
    #   end

    #   # If so, apply discount to revenue
    #   tmp_revenue -= (tmp_revenue * (discount_percent/100))

    #   # Add res to accumulator
    #   total_revenue += tmp_revenue
    # end
  end
end
