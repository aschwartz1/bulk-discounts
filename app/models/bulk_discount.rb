class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name
  validates :threshold, presence: true, numericality: { only_integer: true }
  validates :percent_discount, presence: true, numericality: { only_integer: true }

  def self.for_merchant(merchant_id)
    where(merchant_id: merchant_id)
  end

  def self.for_merchant_quantity(merchant_id, quantity)
    raw_discount = where('threshold <= ?', quantity)
      .where(merchant_id: merchant_id)
      .select(:percent_discount)
      .order(percent_discount: :desc)
      .limit(1)
      .pluck(:percent_discount)
      .first

    percent_for(raw_discount)
  end

  private
  def self.percent_for(raw_discount)
    if raw_discount.nil?
      0
    else
      raw_discount / 100.0
    end
  end
end
