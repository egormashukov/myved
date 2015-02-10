# encoding: utf-8

class AgreementsController < ApplicationController
  before_filter :get_deal, :only => [:new, :create, :index]

  def index
    @agreements = @deal.agreements.for_contractor(current_contractor)
  end

  def show
    @agreement = Agreement.find(params[:id])
  end

  def edit
    @agreement = Agreement.find(params[:id])
  end

  def create
    @agreement = @deal.agreements.build(params[:agreement])
    @agreement.contractor = current_contractor
    
    if @agreement.save
      redirect_to :back, notice: 'соглашение создано'
    else
      redirect_to :back, notice: 'соглашение невозможно создать'
    end

  end

  def update
    @agreement = Agreement.find(params[:id])

    respond_to do |format|
      if @agreement.update_attributes(params[:agreement])
        format.html { redirect_to @agreement, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agreements/1
  # DELETE /agreements/1.json
  def destroy
    @agreement = Agreement.find(params[:id])
    @agreement.destroy

    respond_to do |format|
      format.html { redirect_to agreements_url }
      format.json { head :no_content }
    end
  end

private

  def get_deal
    @deal = Deal.find(params[:deal_id])
  end

end
