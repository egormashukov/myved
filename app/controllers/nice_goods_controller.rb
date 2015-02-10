class NiceGoodsController < ApplicationController
  def index
    @nice_goods = NiceGood.where("title_en LIKE ? OR number LIKE ?", "#{params[:q].downcase}%", "#{params[:q].downcase}%").limit(params[:page_limit])
    respond_to do |format|
      format.json  { render :json => {
        :results => @nice_goods.map{|ng| {id: ng.id, text: ng.coded_title}}
      }}
    end
  end
end
