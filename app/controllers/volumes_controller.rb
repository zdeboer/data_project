class VolumesController < ApplicationController
  def index
    if params[:query].present?
      @volumes = Volume.where("name LIKE ?", "%#{params[:query]}%")
        .order(:name).page(params[:page]).per(20)
    else
      @volumes = Volume.all.order(:name).page(params[:page]).per(20)
    end
  end

  def show
    @volume = Volume.find(params[:id])
  end
end
