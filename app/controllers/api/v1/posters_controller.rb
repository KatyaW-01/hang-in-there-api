class Api::V1::PostersController < ApplicationController
  def index
    if params[:name]
      posters = Poster.filterName(params[:name])
      render json: PosterSerializer.format_posters(posters)
    elsif params[:max_price]
      posters = Poster.maxPrice(params[:max_price])
      render json: PosterSerializer.format_posters(posters)
    elsif params[:min_price]
      posters = Poster.minPrice(params[:min_price])
      render json: PosterSerializer.format_posters(posters)
    elsif params[:sort]
      posters = Poster.sorting(params[:sort])
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
    poster = Poster.create(poster_params)
    render json: PosterSerializer.format_poster(poster)
  end

  def update
    poster = Poster.update(params[:id], poster_params)
    render json: PosterSerializer.format_poster(poster)
  end
  
  def destroy
    render json: Poster.delete(params[:id])
  end

  private
  
    def poster_params
      params.require(:poster).permit(:name,:description,:price,:year,:vintage,:img_url)
    end
    
end