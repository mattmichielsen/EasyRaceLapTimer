class ConfigValue < ActiveRecord::Base
    validates :name, presence: true
    def self.get_value(identifier)
      config_value = ConfigValue.where(name: identifier).first
      if !config_value
        puts "ConfigValue::get_value: #{identifier} not found"
      end
      return config_value
    end

    def self.set_value(identifier,value)
      config_value = ConfigValue.where(name: identifier).first_or_create
      config_value.update(value: value.to_s)
    end

    def self.enable_sound
      enable_sound = get_value("enable_sound")
      if enable_sound.nil?
        ConfigValue.create(name: "enable_sound", value: "true")
        return true
      else
        return enable_sound.value.downcase == "true"
      end
    end

    def self.create_pilot_if_not_exist
      create_if_not_exist = get_value("create_pilot_if_not_exist")
      if create_if_not_exist.nil?
        ConfigValue.create(name: "create_pilot_if_not_exist", value: "false")
        return false
      else
        return create_if_not_exist.value.downcase == "true"
      end
    end
end
