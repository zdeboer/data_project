class IssuesController < ApplicationController
  def index
    @issues = Issue.all.order(:cover_date).page(params[:page]).per(20)
  end

  def show
    @issue = Issue.find(params[:id])
  end
end
