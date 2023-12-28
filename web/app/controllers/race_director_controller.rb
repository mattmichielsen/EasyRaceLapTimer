class RaceDirectorController < ApplicationController
  before_action :filter_needs_race_director_role

  def index
    @race_session_prototype = RaceSession.new
    @custom_soundfiles = CustomSoundfile.order("title ASC")

    @current_race_session = RaceSession::get_open_session
    @current_race_session_adapter = RaceSessionAdapter.new(@current_race_session) if @current_race_session
  end

  def invalidate_lap
    @pilot_race_lap = PilotRaceLap.find(params[:lapid])
    @pilot_race_lap.mark_invalidated
    flash[:notice] = t("messages.invalidated_successfully")
    redirect_to request.referer
  end

  def undo_invalidate_lap
    @pilot_race_lap = PilotRaceLap.find(params[:lapid])
    @pilot_race_lap.undo_invalidated
    flash[:notice] = t("messages.undo_invalidation_successfully")
    redirect_to request.referer
  end

  def add_manual_lap
    session = RaceSession::get_open_session
    lap = PilotRaceLap.new
    lap.race_session_id = session.id
    lap.pilot_id = params[:pilotid]
    lap.lap_num = PilotRaceLap.where(pilot_id: lap.pilot_id, race_session_id: session.id).count + 1
    lap.isManual = true
    lap.save
    redirect_to request.referer
  end

  def lap_times
    @current_race_session = RaceSession::get_open_session
    @current_race_session_adapter = RaceSessionAdapter.new(@current_race_session) if @current_race_session
    render layout: false
  end
end
