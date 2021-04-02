class PilotsController < ApplicationController
  before_action :filter_needs_login

  def index
    @pilots = Pilot.order("name ASC")
    @total_laps = Pilot.all_laps
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
    @total_laps = 0
    @pilots.each do |p|
      @total_laps += p.total_laps
    end
    render 'index'
  end
end
