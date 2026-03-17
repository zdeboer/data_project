class PublishersController < ApplicationController
  def index
    @publishers = Publisher.all.order(:name).page(params[:page]).per(12)
  end

  def show
    @publisher = Publisher.find(params[:id])
  end
end
