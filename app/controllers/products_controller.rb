class ProductsController < ApplicationController
  before_action :set_product, only: [:update, :destroy, :edit]

  def index
    @products = Product.all
    
    respond_to do |format|
      format.html
      format.json { render json: @products }
    end
  end

  def new
    @product = Product.new
  end

  def show
    @product = Product.find(params[:id])
    respond_to do |format|
      format.html 
      format.json { render json: @product }
    end
  end

  def create
    @product = Product.new(product_params)
    respond_to do |format|
      if @product.save
        format.html
        format.json { render json: @product }
      else
        format.json { render json: :unprocessable_entity }
      end
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