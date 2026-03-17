class CharactersController < ApplicationController
  def index
    @publishers = Publisher.all.order(:name)
    @characters = Character.all.order(:name)

    if params[:query].present?
      @characters = @characters.where("name LIKE ? OR real_name LIKE ?",
        "%#{params[:query]}%", "%#{params[:query]}%")
    end

    if params[:publisher_id].present?
      @characters = @characters.where(publisher_id: params[:publisher_id])
    end

    @characters = @characters.page(params[:page]).per(20)
  end

  def show
    @character = Character.find(params[:id])
  end
end
