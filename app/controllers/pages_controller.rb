# encoding: utf-8

class PagesController < ApplicationController
  layout 'landing', :only => [:main]
  
  def main
    if from_abroad?
      render "abroad"
    end
  end

  def show
    @page = Page.find(params[:id])
  end

  def page404
    respond_to do |format|
      format.html { render status: 404 }
    end
  end
end
