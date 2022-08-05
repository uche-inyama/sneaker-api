class SamplesController < ApplicationController
  before_action :set_product, only: [:new, :create]

  def new
    @sample = @product.samples.new
  end

  def create
    @sample = @product.samples.build(sample_params)
    respond_to do |format| 
      if @sample.save
        format.turbo_stream
        format.json {render json: @sample} 
      else
        render status: :unprocessable_entity
      end
    end
  end

  private

  def sample_params
    params.require(:sample).permit(:image)
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end