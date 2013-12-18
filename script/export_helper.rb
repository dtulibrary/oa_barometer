#!/bin/env ruby
# encoding: utf-8
require 'spreadsheet'
require 'json'

module ExportHelper
  
  def write_reingold_tilford_tree_json(json_file,dataset,indices)
    doc_types = Hash.new; sources = Hash.new; topics = Hash.new; general = count_json
    default_size = 3000
    dataset.each do |data|
      doc_type = data[indices["doc_type"]].downcase
      doc_types[doc_type] = default_size if not doc_types.has_key?(doc_type)
      source = data[indices["source"]].downcase
      sources[source] = default_size if not sources.has_key?(source)
      topic = data[indices["topic"]].downcase
      topics[topic] = default_size if not topics.has_key?(topic)
    end
    # order dictionaries
    doc_types = order_dictionary(doc_types)
    sources = order_dictionary(sources)
    topics = order_dictionary(topics)
    
    result = {"name"=>"data", "children"=>Array.new}
    result["children"] << {"name"=>"document types", "children"=>Array.new}
    result["children"] << {"name"=>"sources", "children"=>Array.new}
    result["children"] << {"name"=>"topics", "children"=>Array.new}
    result["children"] << {"name"=>"general", "children"=>Array.new}
    doc_types.keys().each do |doc_type|
      result["children"][0]["children"] << {"name"=>doc_type, "size"=>doc_types[doc_type]}
    end
    sources.keys().each do |source|
      result["children"][1]["children"] << {"name"=>source, "size"=>sources[source]}
    end
    topics.keys().each do |topic|
      result["children"][2]["children"] << {"name"=>topic, "size"=>topics[topic]}
    end
    general.keys().each do |g|
      if not general[g].is_a?(Hash)
        result["children"][3]["children"] << {"name"=>g, "size"=>default_size}
      else
        result["children"][3]["children"] << {"name"=>g, "children"=>Array.new}
        parent_index = result["children"][3]["children"].size - 1  
        general[g].keys().each do |gs|
          result["children"][3]["children"][parent_index]["children"] << {"name"=>gs, "size"=>default_size}
        end
      end
    end
    
    File.open(json_file, 'w') {|f|
      f.write(result.to_json)
    }
  end
  
  def write_json(json_file,dataset,indices)
    sources = Hash.new; publications = Hash.new; doc_types = Hash.new;
    dataset.each do |data|
      doc_type = data[indices["doc_type"]].downcase
      doc_types[doc_type] = count_json if not doc_types.has_key?(doc_type)
    end
    # order doc types
    ordered_doc_types = order_dictionary(doc_types)
    
    publications = doc_types.clone
    open_access = count_json
    topics = {
            "hum"=>count_json,
            "med"=>count_json,
            "sci"=>count_json,
            "soc"=>count_json
            }
    dataset.each do |data|
      # Load fields
      source = data[indices["source"]].downcase
      doc_type = data[indices["doc_type"]].downcase
      topic = data[indices["topic"]].downcase
      oa = (data[indices["oa"]].downcase.eql?("yes") ? "oa" : "non_oa")
      oa_color = (data[indices["sherpa_romeo_color"]].empty? ? "unknown" : data[indices["sherpa_romeo_color"]].downcase)
      # Set source info
      if not sources.has_key?(source)
        sources[source] = {
          "topics"=>{
            "hum"=>count_json,
            "med"=>count_json,
            "sci"=>count_json,
            "soc"=>count_json
            },
          "publications"=>ordered_doc_types.clone
          }
      end
      sources[source]["topics"][topic]["total"] += 1
      sources[source]["topics"][topic][oa] += 1
      sources[source]["topics"][topic]["sherpa_romeo_color"][oa_color] += 1
      sources[source]["publications"][doc_type]["total"] += 1
      sources[source]["publications"][doc_type][oa] += 1
      sources[source]["publications"][doc_type]["sherpa_romeo_color"][oa_color] += 1
      topics[topic]["total"] += 1
      topics[topic][oa] += 1
      topics[topic]["sherpa_romeo_color"][oa_color] += 1
      open_access["total"] += 1
      open_access[oa] += 1
      open_access["sherpa_romeo_color"][oa_color] += 1
      publications[doc_type]["total"] += 1
      publications[doc_type][oa] += 1
      publications[doc_type]["sherpa_romeo_color"][oa_color] += 1
    end
    # Sort sources alphabetically
    ordered_sources = Hash.new
    sources.keys().sort.each do |order|
      ordered_sources[order] = sources[order]
    end
    # Append data used for percentage calculations to general
    open_access["oa_potential_hybrid"] = calculate_oa_percentages(dataset, indices)
    # Write result
    result = {"sources"=>ordered_sources,"topics"=>topics,"general"=>open_access,"publications"=>publications} #TODO: fix namine open_access / general / publications / ??
    File.open(json_file, 'w') {|f|
      f.write(result.to_json)
    }
  end
  
  def write_top_journals(json_file,dataset,indices,doaj_indices,doaj_dict, top_max)
    journals = Hash.new; journal_metadata = Hash.new; journals_topic = Hash.new;
    institutions = Hash.new
    dataset.each do |data|
      issn = clean_id(data[indices["issn"]])
      title = data[indices["journal_title"]]
      topic = data[indices["topic"]].downcase
      oa = data[indices["oa"]].downcase #(data[indices["oa"]].downcase.eql?("yes") ? true : false)
      oa_color = (data[indices["sherpa_romeo_color"]].empty? ? "unknown" : data[indices["sherpa_romeo_color"]].downcase)
      institution = data[indices["source"]].downcase
      next if issn.nil? or issn.empty?# or !oa # Filter on journals and open access
      
      if not institutions.has_key?(institution) # institutions
        institutions[institution] = Hash.new
      end
      
      if not journals_topic.has_key?(topic)
        journals_topic[topic] = Hash.new
      end
      
      if not journals.has_key?(issn) # Journals
        journals[issn] = 1
        journal_metadata[issn] = Hash.new
        if doaj_dict.has_key?(issn) # If registered in DOAJ, select title from DOAJ (better quality)
          journal_metadata[issn]["title"] = doaj_dict[issn][doaj_indices.index("Title")] #TODO: move "Title" out of helper...
          journal_metadata[issn]["oa"] = "yes" # indicates DOAJ Journal status. #TODO: comment this!
        else # Select BFI Journal title (lower quality)
          journal_metadata[issn]["title"] = title
          journal_metadata[issn]["oa"] = "false" # indicates DOAJ Journal status.  #TODO: comment this!
        end
        #journal_metadata[issn]["oa"] = oa # indicates OA conclusion. #TODO: uncomment this!
        journal_metadata[issn]["sherpa_romeo_color"] = oa_color
      else
        journals[issn] += 1
      end
      
      if not institutions[institution].has_key?(issn) # journals by institutions
        institutions[institution][issn] = 1
      else
        institutions[institution][issn] += 1
      end
      
      if not journals_topic[topic].has_key?(issn) # journals by institutions
        journals_topic[topic][issn] = 1
      else
        journals_topic[topic][issn] += 1
      end
    end
    # Sort Hashes
    institutions = Hash[institutions.sort_by{ |k, v| k }] # sort journals based on value in decending order
    journals = Hash[journals.sort_by{ |_, v| -v }] # sort journals based on value in decending order
    journals_topic = Hash[journals_topic.sort_by{|k,v| k}]
    # Write file
    File.open(json_file, 'w') {|f|
      f.write("{") # begin json
      f.write("\"total\":[") # begin total
      journals.each_with_index {|(key,value),index|
        f.write("{")
        f.write("\"issn\":\"#{key}\",")
        f.write("\"count\":#{value},")
        f.write("\"oa\":\"#{journal_metadata[key]["oa"]}\",")
        f.write("\"sherpa_romeo_color\":\"#{journal_metadata[key]["sherpa_romeo_color"]}\",")
        f.write("\"title\":\"#{journal_metadata[key]["title"]}\"")
        if(index == top_max-1)
          f.write("}")
          break
        else
          f.write("}#{(index < journals.keys().size-1 ? "," : "")}")
        end
      }
      f.write("],") # end total
      
      f.write("\"topics\":{") # begin topics
      journals_topic.each_with_index{|(key,value),j_index|
        t = Hash[value.sort_by{ |_,v| -v}] # sort each topic by top journals
        f.write("\"#{key}\":[") # begin topic
        t.each_with_index {|(k,v),index|#each_pair {|k,v|
          f.write("{")
          f.write("\"issn\":\"#{k}\",")
          f.write("\"count\":#{v},")
          f.write("\"oa\":\"#{journal_metadata[k]["oa"]}\",")
          f.write("\"sherpa_romeo_color\":\"#{journal_metadata[k]["sherpa_romeo_color"]}\",")
          f.write("\"title\":\"#{journal_metadata[k]["title"]}\"")
          if(index == top_max-1)
            f.write("}")
            break
          else
            f.write("}#{(index < t.keys().size-1 ? "," : "")}") # end topic
          end
        }
        f.write("]#{(j_index < journals_topic.keys().size-1 ? "," : "")}") # end topic        
      }
      f.write("},") # end topics
      
      f.write("\"institutions\":{") # begin institutions
      institutions.each_with_index{|(key,value),i_index|
        i = Hash[value.sort_by{ |_,v| -v}] # sort each institution by top journals
        f.write("\"#{key}\":[") # begin institution
        i.each_with_index {|(k,v),index|
          f.write("{")
          f.write("\"issn\":\"#{k}\",")
          f.write("\"count\":#{v},")
          f.write("\"oa\":\"#{journal_metadata[k]["oa"]}\",")
          f.write("\"sherpa_romeo_color\":\"#{journal_metadata[k]["sherpa_romeo_color"]}\",")
          f.write("\"title\":\"#{journal_metadata[k]["title"]}\"")
          if(index == top_max-1)
            f.write("}")
            break
          else
            f.write("}#{(index < i.keys().size-1 ? "," : "")}") # end institution
          end
        }
        f.write("]#{(i_index < institutions.keys().size-1 ? "," : "")}") # end institution
      }
      f.write("}") # end institutions
      f.write("}") # end json
      
      #TODO: fix issue, that the first record determines "journal"-open access. Might be true much of the time, but can be faulty?
    }
  end

  def write_spreadsheet(spreadsheet_file,spreadsheet_worksheet,dataset,header)
    # Create workbook and worksheet
    book = Spreadsheet::Workbook.new
    worksheet = book.create_worksheet :name => spreadsheet_worksheet
    # Write and style header
    worksheet.row(0).replace header
    format = Spreadsheet::Format.new :weight => :bold #:color => :blue, :weight => :bold, :size => 18
    worksheet.row(0).default_format = format               
    dataset.each_with_index do |data, index|
      worksheet.row(index+1).replace data
    end
    # Write file
    book.write spreadsheet_file
  end
  
  private
  def calculate_oa_percentages(dataset, indices)
    oa_count = 0; oa_potential_count = 0; oa_hybrid_count = 0; total_count = 0;
    journals_topic = Hash.new;
    accepted_doc_types = {"tidsskrifts-artikel (dja)" => 1, "tidsskrifts-review artikel (djr)"=>1}
    dataset.each do |data|
      issn = clean_id(data[indices["issn"]])
      title = data[indices["journal_title"]]
      topic = data[indices["topic"]].downcase
      oa = data[indices["oa"]].downcase #(data[indices["oa"]].downcase.eql?("yes") ? true : false)
      oa_potential = data[indices["oa_potential"]].downcase
      oa_hybrid = data[indices["oa_hybrid"]].downcase
      doc_type = data[indices["doc_type"]].downcase
      if not journals_topic.has_key?(topic)
        journals_topic[topic] = {"oa"=> 0, "potential" => 0, "hybrid" => 0, "total"=>0}
      end
      
      if not accepted_doc_types.has_key?(doc_type) # Filter out books ect. sice they do not have an OA policy.
        next
      end
      
      total_count += 1
      journals_topic[topic]["total"] += 1
      
      if oa.eql?("yes")
        oa_count += 1
        journals_topic[topic]["oa"] += 1
      end
      if oa_potential.eql?("yes")
        oa_potential_count += 1
        journals_topic[topic]["potential"] += 1
      end
      if oa_hybrid.eql?("yes")
        oa_hybrid_count += 1
        journals_topic[topic]["hybrid"] += 1
      end
    end
    
    puts "Total count = #{total_count}"
    puts "OA count = #{oa_count}"
    puts "OA Potential count = #{oa_potential_count}"
    puts "OA Hybrid count = #{oa_hybrid_count}"
    puts "OA percentage = #{(oa_count.to_f/total_count.to_f)}"
    puts "OA Potential percentage = #{(oa_potential_count.to_f/total_count.to_f)}"
    
    ordered_journals_topic = order_dictionary(journals_topic)
    
    overall = {"total"=>total_count, "oa" => oa_count, "potential" => oa_potential_count, "hybrid" => oa_hybrid_count}
    result = {"overall" =>overall, "topics" => ordered_journals_topic}
    return result
  end
  
  private
  def count_json
    count_json = {
      "total"=>0, "oa"=>0, "non_oa"=>0, "sherpa_romeo_color"=>sherpa_romeo_color_json
      }
    return count_json
  end
  
  private
  def sherpa_romeo_color_json
    oa_color = {
      "blue"=>0, "gray"=>0, "green"=> 0, "white"=>0, "yellow"=> 0, "unknown"=>0
      }
    return oa_color
  end
end