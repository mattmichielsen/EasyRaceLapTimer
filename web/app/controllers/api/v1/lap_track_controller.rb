# frozen_string_literal: true

require "socket"

class Api::V1::LapTrackController < Api::V1Controller
  UDP_BROADCAST_PORT = 33_333

  def create
    @race_session = resolve_race_session
    return render_no_session unless @race_session
    return render_invalid_params if params[:transponder_token].blank? || params[:lap_time_in_ms].blank?
    return render_lap_time_error if lap_time_out_of_bounds?

    pilot_race_lap = track_lap
    return if pilot_race_lap.nil? # error already rendered in track_lap

    send_udp_broadcast
    render json: pilot_race_lap
  end

  private

  def resolve_race_session
    session = params[:session].blank? ? RaceSession.get_open_session : RaceSession.find(params[:session])
    return session if session

    # Maybe the last one had defined idle time => autostart
    session = RaceSession.get_session_from_previous
    SoundFileWorker.perform_async("sfx_start_race") if session && ConfigValue.enable_sound
    session
  end

  def render_no_session
    render status: :conflict, plain: "no running race session"
  end

  def render_invalid_params
    render status: :conflict, plain: "one or more tracking params are blank: #{params.inspect}"
  end

  def lap_time_out_of_bounds?
    lap_ms = params[:lap_time_in_ms].to_f
    min_ms = ConfigValue.get_value("lap_min_lap_time_in_seconds").value.to_f * 1000
    max_ms = ConfigValue.get_value("lap_max_lap_time_in_seconds").value.to_f * 1000

    return true if lap_ms.positive? && lap_ms < min_ms
    return true if lap_ms >= max_ms

    false
  end

  def render_lap_time_error
    lap_ms = params[:lap_time_in_ms].to_f
    min_ms = ConfigValue.get_value("lap_min_lap_time_in_seconds").value.to_f * 1000
    max_ms = ConfigValue.get_value("lap_max_lap_time_in_seconds").value.to_f * 1000

    message = if lap_ms.positive? && lap_ms < min_ms
      "NOT TRACKED: request successful but lap time was less than min lap time: #{min_ms} t: #{lap_ms}"
    else
      "NOT TRACKED: request successful but lap time reached max lap time max: #{max_ms} t: #{lap_ms}"
    end
    render status: :forbidden, plain: message
  end

  def track_lap
    RaceSessionAdapter.new(@race_session).track_lap_time(
      params[:transponder_token],
      params[:lap_time_in_ms],
      params[:is_retry],
      params[:lap_id]
    )
  rescue StandardError => e
    Rails.logger.error { "#{e.message}\n#{e.backtrace.join("\n")}" }
    render status: :forbidden, plain: e.message
    nil
  end

  def send_udp_broadcast
    host = ConfigValue.get_value("udp_broadcast_address").value.to_s.strip
    return if host.empty?

    port = UDP_BROADCAST_PORT
    UDPSocket.open do |sock|
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      sock.send(RaceSessionAdapter.new(@race_session).monitor_data.to_json, 0, host, port)
    end
  end
end
