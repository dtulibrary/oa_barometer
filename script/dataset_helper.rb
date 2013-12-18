require './parsing_helper.rb'
require './export_helper.rb'
module DatasetHelper
  include ParsingHelper
  include ExportHelper
  
  # Clean ids (intended for ISSN / ISBN - removal of spacing etc.)
  def clean_id(id)
    if id != nil
      id.gsub!(/-|\s|\t/,'')
      id.downcase!
    end
    return id
  end
  
  def has_fulltext(result, ddf_header)
    ddf_fulltext_uri_index = ddf_header.index("full_text_uri")
    ddf_fulltext_type_index = ddf_header.index("full_text_type")
    ddf_fulltext_type = (result.has_key?("ddf") ? result["ddf"][ddf_fulltext_type_index] : "")
    ddf_fulltext_uri = (result.has_key?("ddf") ? result["ddf"][ddf_fulltext_uri_index] : "")
    #TODO: what about "pre" ??
    return ((!ddf_fulltext_type.nil? and !ddf_fulltext_type.empty? and (ddf_fulltext_type.eql?("pos") or ddf_fulltext_type.eql?("pub") )) and 
      (!ddf_fulltext_uri.nil? and !ddf_fulltext_uri.empty?) )
  end
  
  # OA Actual = DOAJ or Fulltext URI (type = pre or pub)
  def oa_conclusion_actual(result, ddf_header, sherpa_header)
    fulltext_conclusion = has_fulltext(result, ddf_header)
    return ((fulltext_conclusion or result.has_key?("doaj")) ? "Yes" : "No")
  end
  
  # OA Potential = OA Actual + SHERPA Pver or Post ("Yes" in field)
  def oa_conclusion_potential(result, ddf_header, sherpa_header)
    sherpa_post_index = sherpa_header.index("Post")
    sherpa_pver_index = sherpa_header.index("Pver") #TODO: post is covered in actual...
    sherpa_conclusion = ((result.has_key?("sherpa") and (result["sherpa"].size > sherpa_pver_index and
                          result["sherpa"][sherpa_pver_index].eql?("Yes"))) ? true : false)
    sherpa_conclusion = ((result.has_key?("sherpa") and (result["sherpa"].size > sherpa_post_index and
                          result["sherpa"][sherpa_post_index].eql?("Yes"))) ? true : sherpa_conclusion)
    return ( (sherpa_conclusion or oa_conclusion_actual(result, ddf_header, sherpa_header).eql?("Yes")) ? "Yes" : "No")          
  end
  
  # OA Hybrid = OA Potential + SHERPA Paid ("Yes" in Paid field)
  def oa_conclusion_hybrid(result, ddf_header, sherpa_header)
    sherpa_paid_index = sherpa_header.index("Paid")
    sherpa_conclusion = ((result.has_key?("sherpa") and (result["sherpa"].size > sherpa_paid_index and
                          result["sherpa"][sherpa_paid_index].eql?("Yes"))) ? true : false)
    return ( (sherpa_conclusion or oa_conclusion_potential(result, ddf_header, sherpa_header).eql?("Yes")) ? "Yes" : "No")
  end
  
  def order_dictionary(dictionary)
    ordered_dictionary = Hash.new
    dictionary.keys().sort.each do |order|
      ordered_dictionary[order] = dictionary[order]
    end
    return ordered_dictionary
  end
  
end