#!/bin/env ruby
# encoding: utf-8
require 'spreadsheet'
require 'json'

module ParsingHelper
  
  def parse_spreadsheet(spreadsheet_file,spreadsheet_worksheet,dict_index,header_index,category_header_index=nil, regex_clean_index=nil, downcase_index=false)
    spreadsheet_category_header = Array.new
    spreadsheet_header = Array.new
    spreadsheet_dict = Hash.new
    # Load excel sheet
    Spreadsheet.open(spreadsheet_file) do |book|
      book.worksheet(spreadsheet_worksheet).each_with_index do |row, index|
        spreadsheet_category_header = row.join('||').split('||') if not category_header_index.nil? and index == category_header_index-1 # a bit of a hack, but ensures correct result. #TODO: find a more pretty way to do it !
        next unless index >= header_index-1
        break if row[header_index].nil?
        if spreadsheet_header.size == 0
          spreadsheet_header = row.join('||').split('||') # a bit of a hack, but ensures correct result. #TODO: find a more pretty way to do it !
          if not spreadsheet_category_header.empty?
            spreadsheet_header.each_with_index do |key,key_index|
              category = ""
              key_index.downto(0).each do |category_index|
                next if category_index >= spreadsheet_category_header.size
                category = spreadsheet_category_header[category_index]
                next if category.empty?
                spreadsheet_header[key_index] = "#{category} #{key}"
                break
              end
            end
          end
        else
          key_index = spreadsheet_header.index(dict_index)
          puts "Error: #{dict_index} index not found !" and break if key_index.nil?
          row_index = row[key_index]
          # clean index
          row_index.downcase! if downcase_index
          row_index.gsub!(regex_clean_index,'') if regex_clean_index != nil
          if row_index.empty?
            puts "Warning: row skipped due to empty row index"
            next
          end
          # store data
          spreadsheet_dict[row_index] = row.join('||').split('||') # a bit of a hack, but ensures correct result. #TODO: find a more pretty way to do it !
        end
      end
    end
    return spreadsheet_header, spreadsheet_dict
  end
  
  def parse_csv(csv_file, dict_indices, separator="||", regex_sub=nil, regex_clean=nil, regex_clean_index=nil, downcase_index=false)
    csv_header = Array.new
    csv_dict = Hash.new
    error = false
    redundant_count = 0
    # Load CSV file
    File.open(csv_file,'r').each do |line|
      # clean line
      line.gsub!(/\n|\r/,'')
      line.gsub!(regex_sub[0],regex_sub[1]) if regex_sub != nil
      line.gsub!(regex_clean,'') if regex_clean != nil 
      if csv_header.empty? # set header
        csv_header = line.split(separator)
      else # set data (dictionary)
        record = line.split(separator)
        record_index = create_record_index(dict_indices,record,csv_header,regex_clean_index, downcase_index)
        break if record_index.nil?
        redundant_count += 1 if csv_dict.has_key?(record_index)
        csv_dict[record_index] = record
      end
    end
    puts "Parsing: redundant count was = #{redundant_count}"
    return csv_header, csv_dict
  end
  
  # Create a dictionary from the given data with the given key
  def reindex_dictionary_with_key(dict_indices, dict_header, dict_values,regex_clean_index=nil, downcase_index=false)
    reindexed_dict = Hash.new
    error = false
    dict_values.each do |record|      
      record_index = create_record_index(dict_indices,record,dict_header,regex_clean_index, downcase_index)
      break if record_index.nil?
      next if record_index.empty? # exclude record if the key is empty.
      reindexed_dict[record_index] = Array.new if not reindexed_dict.has_key?(record_index)
      reindexed_dict[record_index] << record
    end
    return reindexed_dict
  end
  
  private
  def create_record_index(dict_indices,record,dict_header,regex_clean_index=nil, downcase_index=false)
    record_index = ''
    error = false
    dict_indices.each do |dict_index|
      key_index = dict_header.index(dict_index)
      puts "Error: #{dict_index} index not found !" and error=true if key_index < 0
      if record.size <= key_index
        puts "Error: #{dict_index} index not present in record=#{record}"
        return nil
      end
      record_index += record[key_index]
    end
    return nil if error
    record_index.downcase! if downcase_index
    record_index.gsub!(regex_clean_index,'') if regex_clean_index != nil
    return record_index
  end
  
end