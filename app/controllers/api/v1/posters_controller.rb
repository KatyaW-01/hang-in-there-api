class Api::V1::PostersController < ApplicationController
  def index
    if params[:name]
      posters = Poster.where("LOWER(name) LIKE?", "%#{params[:name]}%")
      render json: PosterSerializer.format_posters(posters)
    elsif params[:max_price]
      posters = Poster.where("price <= #{params[:max_price]}")
      render json: PosterSerializer.format_posters(posters)
    elsif params[:min_price]
      posters = Poster.where("price >= #{params[:min_price]}")
      render json: PosterSerializer.format_posters(posters)
    else
      posters = Poster.all
      render json: PosterSerializer.format_posters(posters)
    end

  end


  def show
    poster = Poster.find(params[:id])
    render json: PosterSerializer.format_poster(poster)
  end
  
  def create
    render json: Poster.create(poster_params)
  end

  def destroy
    render json: Poster.delete(params[:id])
  end

  private

    def poster_params
      params.require(:poster).permit(:name,:description,:price,:year,:vintage,:img_url)
    end

end