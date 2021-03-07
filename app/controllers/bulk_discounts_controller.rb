class BulkDiscountsController < ApplicationController
  def index
    @bulk_discounts = BulkDiscount.for(params[:merchant_id])
    @merchant_id = params[:merchant_id]
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
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

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    @bulk_discount = BulkDiscount.find(params[:id])

    if @bulk_discount.update(bulk_discount_params)
      render :show
    else
      flash[:error] = 'Failed to update bulk discount!'
      redirect_to edit_merchant_bulk_discount_path(id: @bulk_discount.id, merchant_id: params[:merchant_id])
    end
  end

  def destroy
    BulkDiscount.find(params[:id]).destroy
    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
  end

  private
  def bulk_discount_params
    params
      .require(:bulk_discount)
      .permit(:name, :threshold, :percent_discount)
      .merge(params.permit(:merchant_id))
  end
end
