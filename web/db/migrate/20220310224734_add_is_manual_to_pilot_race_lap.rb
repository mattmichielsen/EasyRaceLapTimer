class AddIsManualToPilotRaceLap < ActiveRecord::Migration
  def change
    add_column :pilot_race_laps, :isManual, :boolean
  end
end
