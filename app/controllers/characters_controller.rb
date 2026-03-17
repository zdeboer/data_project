class CharactersController < ApplicationController
  def index
    @characters = Character.all.order(:name).page(params[:page]).per(20)
  end

  def show
    @character = Character.find(params[:id])
  end
end
