class Admin::ProcrastinatorsController < Admin::ApplicationController

  def index
    @procrastinators = Procrastinator.all
  end
end
