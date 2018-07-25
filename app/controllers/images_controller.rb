class ImagesController < ApplicationController
  def index
    @images = Image.order(created_at: :desc)
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)

    if @image.save
      flash[:notice] = 'The image has been added.'
      redirect_to @image
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.require(:image).permit(:url, :title)
  end
end
