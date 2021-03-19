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

  def filter_by_team
    @pilots = Pilot.where(team: params[:team])
    render 'index'
  end
end
