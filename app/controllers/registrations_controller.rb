class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    @user = User.new(user_params)
    @user.save
    render json: @user
  end

  def update
    super
  end


  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation)
  end
end 

  