class BarometerController < ApplicationController
  before_filter :set_instance_variables, :only => [:index]
  attr_accessor :selected_item
  
  def index
    
  end
  
  def frontpage
    
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
