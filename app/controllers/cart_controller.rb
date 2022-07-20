class CartController < ApplicationController
  def add
    @product = Product.find(params[:product_id])
    quantity = params[:quantity]
    current_orderable = @cart.orderables.find_by(product_id: @product.id)
    if current_orderable && quantity > 0
      current_orderable.update(quantity)
    # elsif(quantity <= 0)
    #   current_orderable.destory
    else
      @orderable = @cart.orderables.create(product_id: params[:product_id], quantity: quantity, image: params[:image])
      render json: @orderable
    end
  end

  def remove
    Orderable.find_by(params[:id]).destory
    head :no_content
  end

  private

  def orderable_params
    params.permit(:product_id, :cart_id, :quantity)
  end
end