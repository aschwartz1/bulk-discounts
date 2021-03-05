require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationhips' do
    it { should belong_to :merchant }
  end

  describe 'validations' do
    it { should validate_presence_of(:threshold) }
    it { should validate_numericality_of(:threshold) }
    it { should validate_presence_of(:percent_discount) }
    it { should validate_numericality_of(:percent_discount) }
  end
end
