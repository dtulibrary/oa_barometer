if Rails.env == 'test' and File.exists?("config/oa_barometer.test.json")
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.test.json")))
elsif File.exists?("config/oa_barometer.local.json")
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.local.json")))
else
  BAROMETER_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "oa_barometer.json")))
end

if Rails.env == 'test' and File.exists?("config/journal_top.test.json")
  TOP_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "journal_top.test.json")))
elsif File.exists?("config/journal_top.local.json")
  TOP_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "journal_top.local.json")))
else
  TOP_JSON = ActiveSupport::JSON.decode(File.read(File.join(Rails.root, "config", "journal_top.json")))
end

