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
    if !@pilot
      render json: @pilot, status: 404
      return
    end

    render json: @pilot
  end

  def by_id
    @pilot = Pilot.find_by(external_id: [params[:external_id]])
    if !@pilot
      render json: @pilot, status: 404
      return
    end

    render json: @pilot
  end

  def create
    begin
      incoming = JSON.parse(request.raw_post)
      if incoming.has_key?("external_id")
        existing = Pilot.find_by(external_id: incoming['external_id'])
      end

      if existing
        logger.info "Existing found"
        changed = incoming.reject {|k, v| v.blank?}
        existing.update_attributes(changed)
        if existing.save
          render json: existing, status: 204
        else
          render nothing: true, status: :bad_request
        end
      else
        logger.info "Creating new"
        @pilot = Pilot.new

        @pilot.assign_attributes(incoming)
        if @pilot.save
          render json: @pilot, status: 201
        else
          render nothing: true, status: :bad_request
        end
      end
    rescue Exception => ex
      render status: 400, text: ex.message
    end
  end

  def deactivate
    @pilot = Pilot.find_by(transponder_token: params[:transponder_token])
    if !@pilot
      render json: @pilot, status: 404
      return
    end

    @pilot.update_attribute(:transponder_token, "")
    @pilot.save
    render text: "Success", status: 200
  end
end
