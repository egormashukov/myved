class TransportUnitsController < ApplicationController

  def update
    @transport_unit = TransportUnit.find(params[:id])
    #respond_to удалять нельзя, json ответ нужен для best_in_place
    respond_to do |format|
      if @transport_unit.update_attributes(params[:transport_unit])
        format.json { respond_with_bip(@transport_unit) }
      else
        format.json { respond_with_bip(@transport_unit) }
      end
    end
  end

end
