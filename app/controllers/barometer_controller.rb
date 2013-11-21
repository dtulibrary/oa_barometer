class BarometerController < ApplicationController
  before_filter :set_instance_variables, :only => [:index]
  attr_accessor :selected_item, :menu_items, :selected_topic, :selected_institution
  
  def index
    
  end
  
  def frontpage
    @menu_items = ["Journals", "Topics", "Institutions"]
    @selected_topic = (@selected_topic.nil? ? TOP_JSON["topics"].keys()[0] : @selected_topic)
    @selected_institution = (@selected_institution.nil? ? TOP_JSON["institutions"].keys()[0] : @selected_institution)
  end
  
  def menu
    #puts "The menu is here!"
    #puts params
    @selected_topic = params["sub-selector-topic"]
    @selected_institution = params["sub-selector-institution"]
    
    respond_to do |format|
      format.html # show_rec_horses.html.erb
      format.js   # show_rec_horses.js.erb
    end
  end
  
  def rt_tree
    respond_to do |format|
      format.json
    end
  end
  
  ### Before filter operations ###
  protected
  def set_instance_variables
    @selected_item = params[:selected_item] if params[:selected_item]
  end
  
end
