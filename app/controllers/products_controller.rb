class ProductsController < ApplicationController
  before_action :set_product, only: [:update, :destroy, :edit]

  def index
    @products = Product.all
    render json: @products
  end

  def new
    @product = Product.new
  end

  def show
    @product = Product.find(params[:id])

    render json: @product
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product
    else
      render json: :unprocessable_entity
    end
  end
  
  def edit;end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def product_params
    params.require(:product).permit(:name, :marketing_statement, :product_discount, :product_price)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end