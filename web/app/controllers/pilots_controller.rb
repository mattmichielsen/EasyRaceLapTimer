class PilotsController < ApplicationController
  def index
    @pilots = Pilot.order("name ASC")
  end

  def laps
    @pilot = Pilot.find(params[:id])
  end

  def teams
    @teams = Pilot.select('distinct(team)').map(&:team)
    render :json => @teams
  end
end
