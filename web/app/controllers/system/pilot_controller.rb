require 'csv'

class System::PilotController < SystemController
  def index
    @pilot_prototype = Pilot.new

    @pilots = Pilot.order("name ASC")
  end

  def edit
    @pilot = Pilot.find(params[:id])
  end

  def update
    @pilot = Pilot.find(params[:id])
    if !@pilot.update_attributes(strong_params_pilot)
      flash[:error] = @pilot.errors.full_messages.to_sentence
    end
    redirect_to action: 'index'
  end

  def deactivate_token
    @pilot = Pilot.find(params[:id])
    @pilot.update_attribute(:transponder_token, "")
    redirect_to action: 'index'
  end

  def delete
    @pilot = Pilot.find(params[:id])
    @pilot.transponder_token = nil
    @pilot.save(validate: false)
    @pilot.delete
    redirect_to action: 'index'
  end

  def create
    @pilot = Pilot.new(strong_params_pilot)
    if !@pilot.save
      @pilot_prototype = @pilot
      render action :'index'
    else
      redirect_to action: 'index'
    end
  end

  def strong_params_pilot
    params.require(:pilot).permit(:name,:transponder_token,:external_id,:image,:quad,:team)
  end

  def export
    @pilots = Pilot.all
    respond_to do |format|
      format.csv { send_data @pilots.to_csv, filename: "pilots-#{Date.today}.csv", format: :csv }
    end
  end

  def import
    Pilot.import(params[:file])
    redirect_to action: 'index', notice: "Successfully Imported Data!"
  end

end
