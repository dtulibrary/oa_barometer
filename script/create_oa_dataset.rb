#!/bin/env ruby
# encoding: utf-8
require "./dataset_helper.rb"

include DatasetHelper

### Constants ###
DATA_DIR = "data/"
RESULT_SPREADSHEET = "oa_barometer.xls"
RESULT_WORKSHEET = "OA Barometer"
RESULT_JSON = "oa_barometer.json"
RESULT_CSV = "oa_barometer.csv"
REINGOLD_TILFORD_TREE_JSON = "rt_tree.json"
JOURNAL_TOP_JSON = "journal_top.json"
JOURNAL_TOP_MAX = 100 # Upper limit to the number of journals in each JSON array. (max number of journals in each Top-list)

REGEX_ISSN = /[\dx-]{8}|[\dx-]{9}/i
# BFI data
ALL_RECORDS_SHEET = "all_records 2012 (2011 publikationer).xls" # Name of the spreadsheet file
ALL_RECPRDS_WORKSHEET = "Post Orienteret" # Name of the worksheet in the spreadsheet
ALL_RECORDS_DICT_INDEX = "Identifikation BFI Id" # Unique Column which should serve as dictorinary index (hash key)
ALL_RECORDS_HEADER_INDEX = 6 # Index of the header in the worksheet
ALL_RECORDS_CATEGORY_HEADER_INDEX = 5 # Index of the category header in the worksheet
# DDF data
DDF_CSV_FILE = "ddf2_data.csv" # Name of the DDF data file (Created through 'harvest_ddf.rb')
DDF_CSV_DICT_INDICES = ["rec_source","rec_id"]
DDF_CSV_SEPARATOR = "||"
# DOAJ data
DOAJ_CSV_FILE = "doaj.csv" # Name of the DOAJ data file (downloaded from: http://doaj.org/doaj?func=loadTemplate&template=faq&uiLanguage=en#metadata)
DOAJ_CSV_DICT_INDICES = ["ISSN"]
DOAJ_CSV_SEPARATOR = "||" # This separator is ensured, through 'REGEX_SUB' and 'REGEX_CLEAN'
DOAJ_CSV_REGEX_SUB = [/","/, "||"] # Preprocessing substitution (gsub! on each line [match, substitute_with] ) - Occurs BEFORE 'REGEX_CLEAN'
DOAJ_CSV_REGEX_CLEAN = /^(")|(")$|/ # Line cleanup (remove that is matched by the expression) - Occurs AFTER 'REGEX_SUB'
DOAJ_CSV_REGEX_CLEAN_INDEX = /[^\dxX]/ # Instructs the parser to remove anything that does not match the expression from the dictionary key.
DOAJ_CSV_DOWNCASE_INDEX = true # Instructs the parser to downcase the dictionary key. (so 1234567X becomes 1234567x)
# SHERPA RoMEO data
SHERPA_SPREADSHEET = "Unique_journal_titles_2011.xls"
SHERPA_WORKSHEET = "Sheet1"
SHERPA_DICT_INDEX = "ISSN" # Unique Column which should serve as dictorinary index (hash key)
SHERPA_HEADER_INDEX = 1 # Index of the header in the worksheet
SHERPA_REGEX_CLEAN_INDEX = /[^\dxX]/ # Instructs the parser to remove anything that does not match the expression from the dictionary key.
SHERPA_DOWNCASE_INDEX = true # Instructs the parser to downcase the dictionary key. (so 1234567X becomes 1234567x)


### Parse All Records Spreadsheet (BFI) ###
bfi_header, bfi_dict = parse_spreadsheet(
  "#{DATA_DIR}#{ALL_RECORDS_SHEET}",
  ALL_RECPRDS_WORKSHEET,
  ALL_RECORDS_DICT_INDEX,
  ALL_RECORDS_HEADER_INDEX,
  ALL_RECORDS_CATEGORY_HEADER_INDEX
)

puts "BFI Header = #{bfi_header}"

puts "BFI Index First Key = #{bfi_dict.keys()[0]}"
puts "BFI Index First Value = #{bfi_dict[bfi_dict.keys()[0]]}"
puts "BFI Total number of publications = #{bfi_dict.keys().size}"

### Parse DDF Data ###
ddf_header, ddf_dict = parse_csv(
  "#{DATA_DIR}#{DDF_CSV_FILE}",
  DDF_CSV_DICT_INDICES,
  DDF_CSV_SEPARATOR
)

puts "DDF Header = #{ddf_header}"
puts "DDF Index First Key = #{ddf_dict.keys()[0]}"
puts "DDF Index First Value = #{ddf_dict[ddf_dict.keys()[0]]}"
puts "DDF Total number of publications = #{ddf_dict.keys().size}"

### Parse DOAJ Data ###
doaj_header, doaj_dict = parse_csv(
  "#{DATA_DIR}#{DOAJ_CSV_FILE}",
  DOAJ_CSV_DICT_INDICES,
  DOAJ_CSV_SEPARATOR,
  DOAJ_CSV_REGEX_SUB,
  DOAJ_CSV_REGEX_CLEAN,
  DOAJ_CSV_REGEX_CLEAN_INDEX,
  DOAJ_CSV_DOWNCASE_INDEX
)

puts "DOAJ Header = #{doaj_header}"
puts "DOAJ Index First Key = #{doaj_dict.keys()[0]}"
puts "DOAJ Index First Value = #{doaj_dict[doaj_dict.keys()[0]]}"
puts "DOAJ Total number of publications = #{doaj_dict.keys().size}"


### Parse SHERPA/RoMEO Data ###
sherpa_header, sherpa_dict = parse_spreadsheet(
  "#{DATA_DIR}#{SHERPA_SPREADSHEET}",
  SHERPA_WORKSHEET,
  SHERPA_DICT_INDEX,
  SHERPA_HEADER_INDEX,
  nil,
  SHERPA_REGEX_CLEAN_INDEX,
  SHERPA_DOWNCASE_INDEX
)


puts "SHERPA Header = #{sherpa_header}"
puts "SHERPA Index First Key = #{sherpa_dict.keys()[0]}"
puts "SHERPA Index First Value = #{sherpa_dict[sherpa_dict.keys()[0]]}"
puts "SHERPA Total number of records = #{sherpa_dict.keys().size}"

### Create Resulting Dataset ###
results = Array.new

ddf_hits = 0; doaj_hits = 0; sherpa_hits = 0;

## Mapping BFI to DDF
# ISSN / ISBN
# Issue / Volumne (not pages! since they often differ)
# Title
# NOTE: ID / PURE ID - can not be used alone since the same publication may have several different PURE Ids, due to multiple registrations
# NOTE: There ISBN exists in TWO indexes for BFI data (due to redundancy in spreadsheet)

# Load important indices
bfi_issn_index = bfi_header.index("Tidsskriftsartikler ISSN")
bfi_isbn_book_index = bfi_header.index("Bøger ISBN")
bfi_isbn_book_contrib_index = bfi_header.index("Bogbidrag ISBN")
bfi_isbn_thesis_index = bfi_header.index("Afhandlinger ISBN")
bfi_title_index = bfi_header.index("Publikation BFI Title")

ddf_rec_source_index = ddf_header.index("rec_source")
ddf_issn_index = ddf_header.index("issn")
ddf_isbn_index = ddf_header.index("isbn")
ddf_title_index = ddf_header.index("full_title")

ddf_issn_dict = nil; ddf_isbn_dict = nil; doaj_eissn_dict = nil;

bfi_dict.keys().each do |bfi_id|
  bfi_record = bfi_dict[bfi_id]
  bfi_issn = clean_id((bfi_record.size > bfi_issn_index ? bfi_record[bfi_issn_index] : nil))
  bfi_isbn_book = clean_id((bfi_record.size > bfi_isbn_book_index ? bfi_record[bfi_isbn_book_index] : nil))
  bfi_isbn_book_contrib = clean_id((bfi_record.size > bfi_isbn_book_contrib_index ? bfi_record[bfi_isbn_book_contrib_index] : nil))
  bfi_isbn_thesis = clean_id((bfi_record.size > bfi_isbn_thesis_index ? bfi_record[bfi_isbn_thesis_index] : nil))
  #bfi_isbn = clean_id((bfi_record.size > bfi_isbn_index ? bfi_record[bfi_isbn_index] : nil))
  bfi_title = bfi_record[bfi_title_index].downcase
  
  result_record = {"bfi"=>bfi_record}
  # Map to DDF
  if ddf_dict.has_key?(bfi_id) # Match on ID
    ddf_record = ddf_dict[bfi_id]
    result_record["ddf"] = ddf_record
    ddf_hits += 1
  else # Match on Title, ISBN, ISSN, Vol, Issue
    ddf_issn_dict = reindex_dictionary_with_key(['issn'], ddf_header, ddf_dict.values(), /[^\dxX]/, downcase_index=true) if ddf_issn_dict.nil?
    ddf_isbn_dict = reindex_dictionary_with_key(['isbn'], ddf_header, ddf_dict.values(), /[^\dxX]/, downcase_index=true) if ddf_isbn_dict.nil?
    if ddf_issn_dict.has_key?(bfi_issn) # Match ISSN
      ddf_issn_dict[bfi_issn].each do |ddf_issn_record| # iterate through all records matching bfi_issn
        ddf_title = ddf_issn_record[ddf_title_index].downcase
        if bfi_title.eql?(ddf_title) # Match title
          ddf_record_index = create_record_index(DDF_CSV_DICT_INDICES,ddf_issn_record,ddf_header)
          result_record["ddf"] = ddf_dict[ddf_record_index] if not ddf_record_index.nil? and not ddf_record_index.empty?
          ddf_hits += 1 if not ddf_record_index.nil? and not ddf_record_index.empty?
          #puts "Record=#{ddf_record_index}, BFI Title=#{bfi_title}, DDF Title=#{ddf_title}"
          #TODO: consider if further verification is needed.. Vol ? Issue ? (these cannot always be expected to be there? or can they?)
        end
      end
    elsif ddf_isbn_dict.has_key?(bfi_isbn_book) # Match ISBN (book)
      ddf_isbn_dict[bfi_isbn_book].each do |ddf_isbn_record| # iterate through all records matching bfi_isbn
        ddf_title = ddf_isbn_record[ddf_title_index].downcase
        if bfi_title.eql?(ddf_title) # Match title
          ddf_record_index = create_record_index(DDF_CSV_DICT_INDICES,ddf_isbn_record,ddf_header)
          result_record["ddf"] = ddf_dict[ddf_record_index] if not ddf_record_index.nil? and not ddf_record_index.empty?
          ddf_hits += 1 if not ddf_record_index.nil? and not ddf_record_index.empty?
          #puts "Record=#{ddf_record_index}, BFI Title=#{bfi_title}, DDF Title=#{ddf_title}"
          #TODO: consider if further verification is needed.. Vol ? Issue ? (these cannot always be expected to be there? or can they?)
        end
      end
    elsif ddf_isbn_dict.has_key?(bfi_isbn_book_contrib) # Match ISBN (book contribution)
      ddf_isbn_dict[bfi_isbn_book_contrib].each do |ddf_isbn_record| # iterate through all records matching bfi_isbn
        ddf_title = ddf_isbn_record[ddf_title_index].downcase
        if bfi_title.eql?(ddf_title) # Match title
          ddf_record_index = create_record_index(DDF_CSV_DICT_INDICES,ddf_isbn_record,ddf_header)
          result_record["ddf"] = ddf_dict[ddf_record_index] if not ddf_record_index.nil? and not ddf_record_index.empty?
          ddf_hits += 1 if not ddf_record_index.nil? and not ddf_record_index.empty?
          #puts "Record=#{ddf_record_index}, BFI Title=#{bfi_title}, DDF Title=#{ddf_title}"
          #TODO: consider if further verification is needed.. Vol ? Issue ? (these cannot always be expected to be there? or can they?)
        end
      end
    elsif ddf_isbn_dict.has_key?(bfi_isbn_thesis) # Match ISBN (thesis)
      ddf_isbn_dict[bfi_isbn_thesis].each do |ddf_isbn_record| # iterate through all records matching bfi_isbn
        ddf_title = ddf_isbn_record[ddf_title_index].downcase
        if bfi_title.eql?(ddf_title) # Match title
          ddf_record_index = create_record_index(DDF_CSV_DICT_INDICES,ddf_isbn_record,ddf_header)
          result_record["ddf"] = ddf_dict[ddf_record_index] if not ddf_record_index.nil? and not ddf_record_index.empty?
          ddf_hits += 1 if not ddf_record_index.nil? and not ddf_record_index.empty?
          #puts "Record=#{ddf_record_index}, BFI Title=#{bfi_title}, DDF Title=#{ddf_title}"
          #TODO: consider if further verification is needed.. Vol ? Issue ? (these cannot always be expected to be there? or can they?)
        end
      end
    end
  end
  # Map to DOAJ
  if bfi_issn != nil and doaj_dict.has_key?(bfi_issn) # Match on ISSN # doaj key must be cleaned! and case insensitive...
    doaj_record = doaj_dict[bfi_issn]
    result_record["doaj"] = doaj_record
    doaj_hits += 1
  elsif result_record.has_key?("ddf") and doaj_dict.has_key?(clean_id(result_record["ddf"][ddf_issn_index])) # Match on DDF data
    doaj_record = doaj_dict[clean_id(result_record["ddf"][ddf_issn_index])]
    result_record["doaj"] = doaj_record
    doaj_hits += 1
  else # Match on EISSN, Title, ... ?
    #TODO: add orther matching criteria if needed....
  end
  # Map to SHERPA / RoMEO
  if bfi_issn != nil and sherpa_dict.has_key?(bfi_issn) # Match on ISSN
    sherpa_record = sherpa_dict[bfi_issn]
    result_record["sherpa"] = sherpa_record
    sherpa_hits += 1
  end
  
  results << result_record
end

puts "DDF_HITS = #{ddf_hits}, DOAJ_HITS = #{doaj_hits}, SHERPA_HITS = #{sherpa_hits}"

unwanted_classification_types = {"book_level1"=>1, "in_book_level1"=>1, "none"=>1}
accepted_doc_review_types = {"Peer review (pr)"=>1}
unwanted_insitutions = {
  "Alexandra Instituttet"=>1,
  "Alexandra Instituttet A/S"=>1#,
  #"Statsbiblioteket"=>1 #TODO: this might need to be included under another university!
  }
institution_translation = {
  "Copenhagen Business School" => "Copenhagen Business School",
  "Aalborg Universitet" => "Aalborg University",
  "Aarhus Universitet" => "Aarhus University",
  "Københavns Universitet" => "University of Copenhagen",
  "IT-Universitetet i København" => "IT University of Copenhagen",
  "Danmarks Tekniske Universitet" => "Technical University of Denmark",
  "Roskilde Universitet" => "Roskilde University",
  "Syddansk Universitet" => "University of Southern Denmark" #"SDU"
}

# Structure result
header_map = [
  # General
  ["bfi","Identifikation BFI Id"],
  ["ddf","rec_id"],
  ["bfi","Publikation BFI Title"],
  ["condition","Identifikation Level"],
  ["bfi","BFI Point relateret BFI Forfattere"],
  # Journal
  ["bfi","Tidsskriftsartikler Tidsskrifts Titel"],
  ["bfi","Tidsskriftsartikler Vol."],
  ["bfi","Tidsskriftsartikler Iss."],
  ["bfi","Tidsskriftsartikler ISSN"],
  # Book
  ["bfi","Bøger Forlag"],
  ["bfi","Publikation Publikationsår"],
  # BFI
  ["condition","Identifikation BFI Classification"], # This is condition, because we filter certain classification types out.
  ["bfi","Identifikation BFI Hovedområde"],
  ["bfi","Tidsskriftsartikler Niveau"],
  
  #TODO: ISI indekseret?
  ["bfi","BFI Point relateret MXD doc_type"], #kan også findes i ddf
  ["condition","BFI Point relateret MXD doc_review"],  # This is condition, because we filter certain types out. #kan også findes i ddf
  # Open Access
  ["condition","Fuldtekst"], #"Yes" / "No"
  ["ddf","full_text_type"],
  ["ddf","full_text_uri"],
  ["condition","DOAJ journal"],
  ["doaj","Publication fee"],
  ["sherpa","Pre"],
  ["sherpa","Post"],
  ["sherpa","Pver"],
  ["sherpa","Paid"],
  ["sherpa","Color"],
  # ["condition","Open Access potential"],
  ["condition","Open Access konklusion"],
  ["condition","Open Access potentiale"],
  ["condition","Open Access hybrid"],
  ["condition","Lokal revision"],
  ["condition","Hvor / Verifikation"]
  ]
result_dataset = Array.new
result_header = Array.new
results.each do |result|
  data = Array.new
  save_result = true
  header_map.each_with_index do |pair, i|
    result_header[i] = pair[1]
    header_index = -1
    if pair[0].eql?("bfi")
      header_index = bfi_header.index(pair[1])
    elsif pair[0].eql?("ddf")
      header_index = ddf_header.index(pair[1])
    elsif pair[0].eql?("doaj")
      header_index = doaj_header.index(pair[1])
    elsif pair[0].eql?("sherpa")
      header_index = sherpa_header.index(pair[1])
    elsif pair[0].eql?("condition") # Conditional fields
      if pair[1].eql?("Open Access konklusion") # Open access conclusion
        data[i] = oa_conclusion_actual(result, ddf_header, sherpa_header)
      elsif pair[1].eql?("Open Access potentiale") # Open access (potential) conclusion
        data[i] = oa_conclusion_potential(result, ddf_header, sherpa_header)
      elsif pair[1].eql?("Open Access hybrid") # Open access (hybrid) conclusion
        data[i] = oa_conclusion_hybrid(result, ddf_header, sherpa_header)
      elsif pair[1].eql?("Fuldtekst")
        data[i] = (has_fulltext(result,ddf_header) ? "Yes" : "No")
      elsif pair[1].eql?("Identifikation BFI Classification")
        header_index = bfi_header.index(pair[1])
        if result.has_key?("bfi") and result["bfi"].size > header_index
          if unwanted_classification_types.has_key?(result["bfi"][header_index])
            save_result = false and break
          end
          data[i] = result["bfi"][header_index]
        else
          data[i] = ''
        end
      elsif pair[1].eql?("BFI Point relateret MXD doc_review")
        header_index = bfi_header.index(pair[1])
        if result.has_key?("bfi") and result["bfi"].size > header_index
          if not accepted_doc_review_types.has_key?(result["bfi"][header_index])
            save_result = false and break
          end
          data[i] = result["bfi"][header_index]
        else
          data[i] = ''
        end  
      elsif pair[1].eql?("Identifikation Level") # Source
        level1_index = bfi_header.index("#{pair[1]}1")
        if result["bfi"][level1_index].eql?("SDU")
          data[i] = "Syddansk Universitet"
        else
          level2_index = bfi_header.index("#{pair[1]}2")
          data[i] = (result["bfi"][level1_index].include?("Videnbasen for") ? result["bfi"][level2_index] : result["bfi"][level1_index])
        end
        
        if data[i].eql?("Statsbiblioteket")
          data[i] = "Aarhus Universitet"
        end
        
        if unwanted_insitutions.has_key?(data[i]) # filter out results from unwanted institutions
          save_result = false and break
        end
        
        if not institution_translation.has_key?(data[i])
          puts "Missing institution! '#{data[i]}'"
        end
        data[i] = institution_translation[data[i]]
      elsif pair[1].eql?("DOAJ journal")
        data[i] = (result.has_key?("doaj") ? "Yes" : "No")
      elsif pair[1].eql?("Lokal revision") or pair[1].eql?("Hvor / Verifikation") # Blank fields
        data[i] = ""
      end
      next
    end
    
    if result.has_key?(pair[0]) and result[pair[0]].size > header_index
      data[i] = result[pair[0]][header_index]
    else
      data[i] = ''
    end
  end
  if save_result
    result_dataset << data
  end
end

# Output result
write_spreadsheet("#{DATA_DIR}#{RESULT_SPREADSHEET}",RESULT_WORKSHEET,result_dataset,result_header)

# Export data to csv file.
File.open("#{DATA_DIR}#{RESULT_CSV}", 'w') {|f|
  f.write(result_header.join('||')+"\n")
  result_dataset.each do |record|
    f.write(record.join('||')+"\n")
  end
  }
  
# Configure result indices to be used in json file generation
result_indices = Hash.new
result_indices["source"] = result_header.index("Identifikation Level")
result_indices["topic"] = result_header.index("Identifikation BFI Hovedområde")
result_indices["doc_type"] =result_header.index("BFI Point relateret MXD doc_type")#("Identifikation BFI Classification")
result_indices["oa"] = result_header.index("Open Access konklusion")
result_indices["oa_potential"] = result_header.index("Open Access potentiale")
result_indices["oa_hybrid"] = result_header.index("Open Access hybrid")
result_indices["sherpa_romeo_color"] = result_header.index("Color") # earlier "oa_color"
result_indices["issn"] = result_header.index("Tidsskriftsartikler ISSN")
result_indices["journal_title"] = result_header.index("Tidsskriftsartikler Tidsskrifts Titel")
# Write json files for web service
write_json("#{DATA_DIR}#{RESULT_JSON}",result_dataset,result_indices)
write_reingold_tilford_tree_json("#{DATA_DIR}#{REINGOLD_TILFORD_TREE_JSON}",result_dataset,result_indices)
write_top_journals("#{DATA_DIR}#{JOURNAL_TOP_JSON}",result_dataset,result_indices,doaj_header,doaj_dict,JOURNAL_TOP_MAX)

puts "Done!"
