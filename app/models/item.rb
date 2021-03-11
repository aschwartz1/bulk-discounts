class Item < ApplicationRecord
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  belongs_to :merchant
  # TODO add test
  has_many :bulk_discounts, through: :merchant

  validates :name, presence: true, length: { minimum: 3 }
  validates :description, presence: true, length: { minimum: 15, maximum: 500 }
  validates :unit_price, numericality: true

  enum status: [:disabled, :enabled]

  def self.enabled
    where(status: :enabled)
    .order(:id)
  end

  def self.disabled
    where(status: :disabled)
    .order(:id)
  end

  def self.max_id
    maximum(:id) + 1
  end

  def best_day
    invoices.joins(:invoice_items)
            .select('invoices.created_at, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue')
            .group('invoices.created_at')
            .order('total_revenue desc, invoices.created_at desc')
            .first
            .created_at
            .strftime('%m/%d/%Y')
  end

  def self.top_five
    joins(invoices: :transactions)
    .where('transactions.result = ?', Transaction.results[:success])
    .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
    .group(:id)
    .order('total_revenue desc')
    .limit(5)
  end
end
