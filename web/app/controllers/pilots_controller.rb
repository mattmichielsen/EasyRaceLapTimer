class PilotsController < ApplicationController
  before_action :filter_needs_login

  def index
    @pilots = Pilot.registered.order("name ASC")
    @total_laps = Pilot.registered.all_laps
  end

  def laps
    @pilot = Pilot.registered.find(params[:id])
  end

  def teams
    @teams = Pilot.registered.select('distinct(team)').map(&:team)
    render :json => @teams
  end

  def filter_by_team
    @pilots = Pilot.registered.where(team: params[:team])
    @total_laps = 0
    @pilots.each do |p|
      @total_laps += p.total_laps
    end
    render 'index'
  end
end
