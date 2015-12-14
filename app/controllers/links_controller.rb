class LinksController < ApplicationController

  def index
    @links = Link.where("user_id = #{current_user.id}")
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.new post_params
    if @link.save
      flash[:notice] = "Link created!"
      render :index
    else
      flash[:notice] = "Link wasn't created."
      render :new
    end
  end

  def edit
    @link = Link.find_by_id params[:id]
  end

  def update
    @link = Link.find_by_id params[:id]
    if @link.update_attributes post_params
      flash[:notice] = "Link updated!"
      render :index
    else
      flash[:notice] = "Link not updated."
      render :edit
    end
  end
  def show
    @link = Link.find_by_id params[:id]
  end
  def destroy
    @link = Link.find_by_id params[:id]
    if @link.destroy
      flash[:notice] = "Link removed"
      render :index
    end
  end

  def parse
    @content = Link.parse(params[:url])
    render json: @content.to_json
  end

  private
    def post_params
      params.require(:links).permit(:url, :name)
    end




end
