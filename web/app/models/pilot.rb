class Pilot < ActiveRecord::Base
  require 'csv'
  #require 'activerecord-import/base'
  #require 'activerecord-import/active_record/adapters/sqlite3'
  validates :transponder_token, uniqueness: true
  has_many :pilot_race_laps, :dependent => :destroy
  acts_as_paranoid
  mount_uploader :image, PilotImageUploader

  def total_races
    return self.pilot_race_laps.group(:race_session_id).count.count
  end

  def total_laps
    self.pilot_race_laps.count
  end
  
  def self.all_laps
    laps = 0
    
    all.each do |p|
      laps += p.total_laps
    end
    return laps
  end
    

  def self.to_csv
    attributes = %w{transponder_token name team}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |p|
        csv << attributes.map{ |attr| p.send(attr) }
      end
    end
  end

  def self.import(file)
    #pilots = []
    CSV.foreach(file.path, headers: true) do |row|
      #pilots <<Pilot.new(row.to_h)
      p = Pilot.new(row.to_h)
      p.save
    end
    #Pilot.import pilots, recursive: true
  end
end
