class VolumesController < ApplicationController
  def index
    @volumes = Volume.all.order(:name).page(params[:page]).per(12)
  end

  def show
    @volume = Volume.find(params[:id])
  end
end
