class Admin::RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
  end

  def create
    byebug
    # @user = User.new(user_params)
    # if @user.save
    #   redirect_to products_path, notice: 'Logged in successfully.'
    # else
    #   render new
    # end
  end

  def update
    super
  end

  private

  def user_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end 

  