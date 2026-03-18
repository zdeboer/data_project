class IssuesController < ApplicationController
  def index
    @volumes = Volume.all.order(:name)
    @issues = Issue.all.order(:cover_date)

    if params[:query].present?
      words = params[:query].split.map { |w| "%#{w}%" }

      conditions = words.map { "name LIKE ? OR description LIKE ?" }.join(" AND ")
      values = words.flat_map { |w| [ w, w ] }

      @issues = @issues.where(conditions, *values)
    end

    if params[:volume_id].present?
      @issues = @issues.where(volume_id: params[:volume_id])
    end

    @issues = @issues.page(params[:page]).per(24)
  end

  def show
    @issue = Issue.find(params[:id])
  end
end
