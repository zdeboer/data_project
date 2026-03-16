class VolumesController < ApplicationController
  def index
    @volumes = Volume.all.order(:name)
  end

  def show
    @volume = Volume.find(params[:id])
  end
end
