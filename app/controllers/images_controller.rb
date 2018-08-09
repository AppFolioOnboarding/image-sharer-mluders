class ImagesController < ApplicationController
  def index
    # get the query string
    # filter
    tag = params['tag']
    @images = if tag.present?
                Image.tagged_with(tag).order(created_at: :desc)
              else
                Image.order(created_at: :desc)
              end
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def edit
    @image = Image.find(params[:id])
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

  def update
    @image = Image.find(params[:id])

    if @image.update(image_params)
      flash[:notice] = 'The image has been updated.'
      redirect_to @image
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    Image.destroy(params[:id])
    flash[:notice] = 'The image has been deleted.'
    redirect_to images_path
  rescue ActiveRecord::RecordNotFound
    render file: 'public/404.html', status: :not_found
  end

  private

  def image_params
    params.require(:image).permit(:url, :title, :tag_list)
  end
end
