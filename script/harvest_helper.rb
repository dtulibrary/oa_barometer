require 'net/http'
require 'uri'
require 'fileutils'
require 'nokogiri'

module HarvestHelper

  # Perform HTTP Get request  
  def http_get(target)
    uri = URI.parse(target)
    response = Net::HTTP.get_response(uri)
    if response.code.to_i == 200
      return true, response.body, response["Content-Type"] # return html
    else
      puts "HTTP Error code: #{response.code}, msg=#{response.msg}, url=#{target}"
      return false,'', ''
    end
  end
  
  # Perform XSLT Transformation
  def transform_xml(xsl_file,xml_doc,params=nil)
    doc   = Nokogiri::XML(xml_doc)
    xslt  = (params.nil? ? Nokogiri::XSLT(File.read("#{xsl_file}")) : Nokogiri::XSLT(File.read("#{xsl_file}"),params))
    csv_doc =  xslt.transform(doc,Nokogiri::XSLT.quote_params(params))
    csv_doc
  end
  
end