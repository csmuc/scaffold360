class <%= controller_class_name %>Controller < ApplicationController
  before_filter :set_dom_prefix
  #after_filter :dump_body

<% unless options[:singleton] -%>
  # GET /<%= table_name %>
  # GET /<%= table_name %>.htmlf
  # GET /<%= table_name %>.xml    
  def index
    #@<%= table_name %> = <%= orm_class.all(class_name) %> # w/o will_paginate
    @<%= table_name %> = <%= class_name %>.paginate(:page => params[:page], :per_page => 2)  # will_paginate

    respond_to do |format|
      format.html
      format.htmlf  { render :partial => 'index' }
      format.js     # "load more"
      #format.xml    { render :xml => @<%= table_name %> }      
    end
  end
<% end -%>

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.htmlf
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      format.html
      format.htmlf  { render :partial => 'show' }
      #format.xml    { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.htmlf
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= orm_class.build(class_name) %>

    respond_to do |format|
      format.html
      format.htmlf  { render :partial=>'new', :object=>@<%= file_name %> }
      #format.xml    { render :xml => @<%= file_name %> }
    end
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.htmlf
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= orm_class.build(class_name, "params[:#{file_name}]") %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html   { redirect_to(@<%= file_name %>, :notice => '<%= human_name %> was successfully created.') }
        format.htmlf  { flash.now[:notice]='<%= human_name %> was successfully created.'; render :partial => 'show', :object=>@<%= file_name %> }
        #format.xml    { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html   { render :action => "new" }
        format.htmlf  { render :partial => 'new', :object=>@<%= file_name %>, :status => :unprocessable_entity }
        #format.xml    { render :xml => @<%= orm_instance.errors %>, :status => :unprocessable_entity }
      end
    end
  end


  # GET /<%= table_name %>/1/edit
  # GET /<%= table_name %>/1/edit.htmlf
  def edit
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_to do |format|
      format.html
      format.htmlf  { render :partial=>'edit', :object=>@<%= file_name %> }
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.htmlf
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{file_name}]") %>
        format.html   { redirect_to(@<%= file_name %>, :notice => '<%= human_name %> was successfully updated.') }
        format.htmlf  { flash.now[:notice]='<%= human_name %> was successfully updated.'; render :partial => 'show', :object=>@<%= file_name %> }
        #format.xml    { head :ok }
      else
        format.html   { render :action  => "edit" }
        format.htmlf  { render :partial => 'edit', :object=>@<%= file_name %>, :status => :unprocessable_entity }
        #format.xml    { render :xml => @<%= orm_instance.errors %>, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.htmlf
  # DELETE /<%= table_name %>/1.xml
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
