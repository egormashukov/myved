# encoding: utf-8

class Admin::PrivaciesController < Admin::ApplicationController

  def toggleshow
    @privacy = privacy_scope.find(params[:id])
    @privacy.toggle(:visible)
    @privacy.save
    render nothing: true
  end

  def index
    @privacies = privacy_scope.where(type: params[:type].try(:camelcase) || 'GeneralRule')
  end

  def new
    @privacy = privacy_scope.new
  end

  def edit
    @privacy = privacy_scope.find(params[:id])
  end

  def create
    @privacy = privacy_scope.build(params[:privacy])

    if @privacy.save
      redirect_to admin_privacies_path, notice: 'правило создано'
    else
      render 'new'
    end

  end

  # def update
  #   @agreement = Privacy.find(params[:id])
  #
  #   respond_to do |format|
  #     if @agreement.update_attributes(params[:pravacy])
  #       format.html { redirect_to @agreement, notice: 'Agreement was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @agreement.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def destroy
    @agreement = Privacy.find(params[:id])
    @agreement.destroy

    respond_to do |format|
      format.html { redirect_to agreements_url }
      format.json { head :no_content }
    end
  end

  private

  def privacy_scope
    Privacy.scoped
  end
end
