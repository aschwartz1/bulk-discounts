class BulkDiscountsController < ApplicationController
  def index
    @discounts = BulkDiscount.for(params[:merchant_id])
  end

  def show

  end
end
