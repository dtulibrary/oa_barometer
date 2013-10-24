if Rails.env == 'test' and File.exists?("config/oa_barometer.test.json")
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.test.json")))
elsif File.exists?("config/oa_barometer.local.json")
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.local.json")))
else
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.json")))
end

