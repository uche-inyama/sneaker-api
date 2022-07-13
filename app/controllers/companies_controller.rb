class CompaniesController < ApplicationController
  before_action :set_company, only: [:edit, :update, :destroy]
  def index
    @companies = Company.all
    render json: @companies
  end

  def create
    @company = Company.create(company_params)
    if @company.save
      render json: @company
    else
      render json: :unprocessable_entity
    end
  end

  def edit;end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head :no_content
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

  def set_company
    @company = Company.find(params[:id])
  end
end