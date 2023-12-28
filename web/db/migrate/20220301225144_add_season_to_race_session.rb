class AddSeasonToRaceSession < ActiveRecord::Migration
  def change
    add_reference :race_sessions, :season, index: true, foreign_key: true
  end
end
