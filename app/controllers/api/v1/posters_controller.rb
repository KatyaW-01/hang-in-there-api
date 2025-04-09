class Api::V1::PostersController < ApplicationController
  def index
    posters = Poster.all
    render json: PosterSerializer.format_posters(posters)
  end




  def destroy
    render json: Poster.delete(params[:id])
  end
end