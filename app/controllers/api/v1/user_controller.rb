module API::V1
  class UserController < ApiController
    before_filter :set_user

    def create
      @user = User.create(user_params)
      render json: @user, status: 200
    rescue
      render json: { error: $!.message, backtrace: $@ }, status: 500
    end

    def show
      @user = User.find_by email: params[:email]
      render json: @user, status: 200
    rescue
      render json: { error: $!.message, backtrace: $@ }, status: 500
    end

    def update
      @user.update_attributes(user_params)
      render json: @user, status: 200
    rescue
      render json: { error: $!.message, backtrace: $@ }, status: 500
    end

    def destroy
      render json: @user, status: 200
    rescue
      render json: { error: $!.message, backtrace: $@ }, status: 500
    end

    def signin

    end

    def signout
    end

    private

      def user_params
        params.require(:user).permit(:name, :email, :password)
      end

      def set_user
        @user = User.find_by params[:id]
      end

  end
end
