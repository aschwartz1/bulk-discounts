class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name
  validates :threshold, presence: true, numericality: { only_integer: true }
  validates :percent_discount, presence: true, numericality: { only_integer: true }

  def self.for(merchant_id)
    where(merchant_id: merchant_id)
  end
end
