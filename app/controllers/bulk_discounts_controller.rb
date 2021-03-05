class BulkDiscountsController < ApplicationController
  def index
    @discounts = BulkDiscount.for(params[:merchant_id])
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end
end
