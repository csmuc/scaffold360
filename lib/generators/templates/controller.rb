class <%= controller_class_name %>Controller < ApplicationController
  self.responder = Scaffold360::HtmlfResponder
  respond_to :html, :htmlf

  before_filter :set_dom_prefix
  #after_filter :dump_body

<% unless options[:singleton] -%>
  def index
    #@<%= table_name %> = <%= orm_class.all(class_name) %> # w/o will_paginate
    @<%= table_name %> = <%= class_name %>.paginate(:page => params[:page], :per_page => 2)  # will_paginate

    respond_with do |format|
      format.js     # "load more"
    end
  end
<% end -%>

  def show
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= file_name %>
  end

  def new
    @<%= file_name %> = <%= orm_class.build(class_name) %>
    respond_with @<%= file_name %>
  end

  def create
    @<%= file_name %> = <%= orm_class.build(class_name, "params[:#{file_name}]") %>
    @<%= orm_instance.save %>
    respond_with @<%= file_name %>
  end


  def edit
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= file_name %>
  end

  def update
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.update_attributes("params[:#{file_name}]") %>
    respond_with @<%= file_name %>
  end

  def destroy
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>

    respond_to do |format|
      format.html { redirect_to(<%= table_name %>_url) }
      format.htmlf  { render :text=>'' }  # TODO
      #format.xml    { head :ok }
    end
  end
  
  
  protected  
    
    def set_dom_prefix
      @_dom_prefix = params[:_dom_prefix]
    end
      
    def dump_body
      puts response.body
    end
  
end
