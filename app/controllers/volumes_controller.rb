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

    if params[:query].present?
      words = params[:query].split.map { |w| "%#{w}%" }
      conditions = words.map { "name LIKE ? OR issue_number LIKE ?" }.join(" AND ")
      values = words.flat_map { |w| [ w, w ] }
      @issues = @volume.issues.where(conditions, *values).order(:issue_number)
    else
      @issues = @volume.issues.order(:issue_number)
    end
  end
end
