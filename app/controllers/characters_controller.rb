class CharactersController < ApplicationController
  def index
    @publishers = Publisher.all.order(:name)
    @characters = Character.all.order(:name)

    if params[:query].present?
      words = params[:query].split.map { |w| "%#{w}%" }

      conditions = words.map { "name LIKE ? OR real_name LIKE ?" }.join(" AND ")
      values = words.flat_map { |w| [ w, w ] }

      @characters = @characters.where(conditions, *values)
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
