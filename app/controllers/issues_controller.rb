class IssuesController < ApplicationController
  def index
    @issues = Issue.all.order(:cover_date)
  end

  def show
    @issue = Issue.find(params[:id])
  end
end
