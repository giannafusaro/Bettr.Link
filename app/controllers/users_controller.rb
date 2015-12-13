class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new post_params
    if @user.save
      flash[:notice] = "Success in creating a user!"
      session[:user_id] = @user.id
      redirect_to dashboard_path(@user.name.parameterize)
    else
      render 'site/home'
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes(post_params)
      flash[:notice] = "Success in updating user!"
      redirect_to dashboard_path(@user.name.parameterize)
    else
      render :edit
    end
  end

  def destroy
    @user = User.find params[:id]
    flash[:notice] = "User destroyed successfully" if @user.destroy
  end

  def login
    @user = User.find_by_email(params[:user][:email])
    if @user
      session[:user_id] = @user.id
      flash[:notice] = "User logged in successfully"
      redirect_to dashboard_path(@user.name.parameterize)
    else
      flash[:notice] = "Couldn't find user, try again"
      render 'site/home'
    end
  end

  def logout
    session.delete(:user_id)
    redirect_to root_path
  end

  private
    def post_params
      params.require(:user).permit(:name, :email, :password)
    end
end
