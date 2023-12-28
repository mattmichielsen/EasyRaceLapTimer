class Pilot < ActiveRecord::Base
  require 'csv'
  validates :transponder_token, uniqueness: true
  validates_uniqueness_of :external_id, :allow_blank => true
  has_many :pilot_race_laps, :dependent => :destroy
  acts_as_paranoid
  mount_uploader :image, PilotImageUploader

  scope :registered, -> {where.not(transponder_token: [nil, ''])}

  def total_races
    return self.pilot_race_laps.group(:race_session_id).count.count
  end

  def total_laps
    self.pilot_race_laps.valid.count
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
    CSV.foreach(file.path, headers: true) do |row|
      p = Pilot.new(row.to_h)
      p.save
    end
  end
end
