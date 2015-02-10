class Admin::ReportsController < Admin::ApplicationController

  def index
  	@report = Report.new(params[:report])
  end
end
