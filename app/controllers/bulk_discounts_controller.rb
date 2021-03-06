class BulkDiscountsController < ApplicationController
  def index
    @bulk_discounts = BulkDiscount.for(params[:merchant_id])
    @merchant_id = params[:merchant_id]
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @bulk_discount = BulkDiscount.new
  end

  def create
    new_discount = BulkDiscount.new(bulk_discount_params)

    if new_discount.save
      redirect_to merchant_bulk_discounts_path(params[:merchant_id])
    else
      flash[:error] = 'Failed to create bulk discount!'
      redirect_to new_merchant_bulk_discount_path(params[:merchant_id])
    end
  end

  private
  def bulk_discount_params
    params
      .require(:bulk_discount)
      .permit(:name, :threshold, :percent_discount)
      .merge(params.permit(:merchant_id))
  end
end
