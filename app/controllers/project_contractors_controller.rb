class ProjectContractorsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_contractor

  def update
    @project_contractor.toggle_archive
    redirect_to :back
  end

  def destroy
    if @project_contractor.archived? || @project_contractor.new?
      @project_contractor.destroy
    else
      @project_contractor.archive
    end
    redirect_to root_path
  end

  private

  def check_contractor
    set_project
    return true if @project_contractor.contractor_id == current_contractor.id
    redirect_to :back, notice: I18n.t(:havent_access)
  end

  def set_project
    @project_contractor = ProjectContractor.find(params[:id])
  end
end
