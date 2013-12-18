require "./harvest_helper.rb"

include HarvestHelper
# Example of HTTP request of publications (in 2010 or 2011)
# http://SERVER:PORT/?version=1.1&operation=searchRetrieve&x-pquery=@attr+1%3dpubyear+@or+2010+2011&maximumRecords=1
# Example of HTTP request of Journal Article publications (in 2010 or 2011)
# http://SERVER:PORT/?version=1.1&operation=searchRetrieve&x-pquery=@and+@attr+1%3ddoctype+dja+@attr+1%3dpubyear+@or+2010+2011&maximumRecords=1
# Example of HTTP request of open access publications (in 2010 or 2011)
# http://SERVER:PORT/?version=1.1&operation=searchRetrieve&x-pquery=@and+@attr+1%3daccess+oa+@attr+1%3dpubyear+@or+2010+2011&maximumRecords=1

if ARGV.size != 2
  puts "Error! Invalid number of arguments: expetect '[SERVER] [PORT]'"
  puts "Example: 'ruby harvest_ddf.rb example.com 8888'"
  exit
end

SERVER = ARGV[0]
PORT = ARGV[1]

### Params ###
years = [2010,2011,2012] # NOTICE ! It is reasonable to add the adjacent years, since years in DDF are more "fluent" than the "snapshot" taken in BFI data.
year_query = ""
if years.size == 3
  year_query = "@attr+1%3dpubyear+@or+#{years[0]}+@or+#{years[1]}+#{years[2]}"
elsif years.size == 2
  year_query = "@attr+1%3dpubyear+@or+#{years[0]}+#{years[1]}"
elsif years.size == 1
  year_query = "@attr+1%3dpubyear+#{years[0]}"
else
  puts "Error! Year query is broken and needs fixing..."
end
open_access_only = false
### Constants ###
ZEBRA_BASE = "http://#{SERVER}:#{PORT}/"
XSL_DOC = "xsl/zebra_to_csv.xsl"
DDF_DATA_FILE = "data/ddf2_data.csv"
MAX_RECORDS = 40000

# Perform HTTP request to get DDF data
url = ''
if open_access_only
  url = "#{ZEBRA_BASE}?version=1.1&operation=searchRetrieve&x-pquery=@and+@attr+1%3daccess+oa+#{year_query}&maximumRecords=#{MAX_RECORDS}"
else
  url = "#{ZEBRA_BASE}?version=1.1&operation=searchRetrieve&x-pquery=#{year_query}&maximumRecords=#{MAX_RECORDS}"
end

is_success, response, content_type = http_get(url)
if is_success and content_type =~ /text\/xml/i
  # Transform DDF data from XML to CSV
  csv_doc = transform_xml(XSL_DOC,response,['includeHeader','yes'])
  csv = csv_doc.text
  # Store data in Array
  records = Array.new
  records = csv.split(/\n/)
    
  # Check that number of records does not exceed max records.
  number_of_records = records.shift.to_i
  if number_of_records > MAX_RECORDS
    puts "Info! Something is amiss! further requests are needed!"
    while(number_of_records>records.size) # harvest until all records are collected
      is_success, response, content_type = http_get("#{url}&startRecord=#{records.size}")
      append_csv_doc = transform_xml(XSL_DOC,response,['includeHeader','no'])
      append_csv = append_csv_doc.text
      # Store data in Array
      append_records = Array.new
      append_records = append_csv.split(/\n/)
      break if append_records.empty? # break if response resulted in no records. Possible because Zebra number of records may not be exact.
      records.concat(append_records) # append records
      puts "Number of records = #{records.size}"
    end
  end
  
  puts "maxRecords = #{MAX_RECORDS}, numberOfRecords = #{number_of_records}, records written to file = #{records.size}"
  puts "Warning! number of records does not match written records" if number_of_records != records.size
  puts "Warning! Header fields does not match data" if records[0].split('||').size != records[1].split('||').size
  
  # Export data to file.
  File.open(DDF_DATA_FILE, 'w') {|f|
    records.each do |record|
      f.write(record+"\n")
    end
    }
else
  puts "Error in Zebra response!"
end