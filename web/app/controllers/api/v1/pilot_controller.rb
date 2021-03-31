class Api::V1::PilotController < Api::V1Controller
  def index
    json_data = Array.new
    Pilot.all.each do |p|
      json_data << p
    end

    render json: json_data.to_json
  end

  def show
    @pilot = Pilot.find_by(transponder_token: params[:transponder_token])
    render json: @pilot
  end

  def create
    begin
      @pilot = Pilot.new
      @pilot.assign_attributes(JSON.parse(request.raw_post))
      if @pilot.save
        render json: @pilot
      else
        render nothing: true, status: :bad_request
      end
    rescue Exception => ex
      render status: 400, text: ex.message
    end
  end
end
