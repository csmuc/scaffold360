
#- htmlf

#- extended :remote param (link_to, form_for, form_tag, JS)
# :remote=>{:update=>'project_list', :position=>:bottom}

# NOT NEEDED ANY LONGER!
#- partial :padding

#- will_paginate extension

# pagination like this?
# scope :paginate, lambda{ |page,per_page| limit(per_page.to_i).offset((page.to_i-1)*per_page.to_i) }

#- generator
# pages: index, show, edit, new
#   full partials: _index, _show, _edit, _new
#     _collection, _project, _form

# http://github.com/robertgaal/facebox-for-prototype

# TODO:
# - http://github.com/rails/rails/commit/7008911222826eef07a338bf4cab27b83fe90ce1
# - CSS (thing.css, ...)
# - shared partial: _error_messages
# - _object -> _<resource> 

# DONE will_paginate -> htmlf format
# DONE "load more" how to update
# DONE - show mit div / edit ohne LB  
# DONE - lightbox / div prefix (enable simult.)
# => page / div / LB durchparametrisieren => nur noch einen edit-link, entsprechendes prefix
# ==> gar nichts, ".project_remote_target"

# DONE - facebox / Ajax update
# DONE - index Ajax / LB

# - generator
#   - JS
# http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators/
# http://guides.rails.info/generators.html
# http://caffeinedd.com/guides/331-making-generators-for-rails-3-with-thor
# http://paulbarry.com/articles/2010/01/13/customizing-generators-in-rails-3

# DONE - htmlf => in Ajax zwecks SEO/degradable links???

# - _index == index ??? (ajax reload whole page)
# - :padding wird noch in _show benötigt
# - jQuery
# - destroy Ajax
# - test-coverage (generate functional tests, test plugin)

module Scaffold360
  module Helper
    def self.convert_remote_to_html_options(options)
      r = options[:remote]
      html_options = {}
      
      # support :update and :replace param
      dom_id = options.delete(:update)
      if r.is_a?(Hash)   # also support extracting the update arg from :remote hash
        dom_id ||= r[:update]
        html_options["data-update-position"] = r[:position] if r[:position]
      end
      
      html_options["data-update-success"] = dom_id if dom_id
        
      # support :replace param
      dom_id = options.delete(:replace)
      dom_id ||= r[:replace] if r.is_a?(Hash)   # also support extracting the update arg from :remote hash
      html_options["data-replace-success"] = dom_id if dom_id
      
      # support :remote => { :format => }
      if r.is_a?(Hash) && (f = r[:format])
        html_options["data-remote-format"] = f
      end
      
      html_options
    end
  end
  
  # :remote support by will_paginate
  if defined?(::WillPaginate::ViewHelpers::LinkRenderer)
    module WillPaginate
      class RemoteLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
        def link(text, target, attributes = {})
          # force to use htmlf mime type
          #@base_url_params||={}        
          #@base_url_params[:format]='htmlf'        

          attributes['data-remote']=true
          attributes.merge! Scaffold360::Helper.convert_remote_to_html_options(@options)
          super(text, target, attributes)
        end
      end
    end
  end  
end


module ActionView
  # patch link_to / form helper methods
  module Helpers
    # patched (IN AN UGLY WAY) form_for to support: :remote => { :replace => :self }, or :remote => { :replace => :self }
    # or :remote => { :update => '123' }
    # Change: Pass :remote param in html hash
    module FormTagHelper
      def html_options_for_form_with_update(url_for_options, options, *parameters_for_url)
        remote_html_options = Scaffold360::Helper.convert_remote_to_html_options(options)
        if remote_html_options.size > 0
          options.merge! remote_html_options
          options[:remote]=true  # kill our hash
        end
        
        html_options_for_form_without_update(url_for_options, options, *parameters_for_url)
      end
      alias_method_chain :html_options_for_form, :update
    end
    
    # link_to
    module UrlHelper
      def convert_options_to_data_attributes_with_update(options, html_options)
        html_options.merge! Scaffold360::Helper.convert_remote_to_html_options(html_options) if html_options.is_a?(Hash)                  
        convert_options_to_data_attributes_without_update(options, html_options)
      end
      
      alias_method_chain :convert_options_to_data_attributes, :update
    end

    
    module FormHelper
      # very unfortunate monkeypatch. form_for needs to support not only remote=true but pass on
      # hashes, too.
      def form_for(record_or_name_or_array, *args, &proc)
        raise ArgumentError, "Missing block" unless block_given?

        options = args.extract_options!

        case record_or_name_or_array
        when String, Symbol
          ActiveSupport::Deprecation.warn("Using form_for(:name, @resource) is deprecated. Please use form_for(@resource, :as => :name) instead.", caller) unless args.empty?
          object_name = record_or_name_or_array
        when Array
          object = record_or_name_or_array.last
          object_name = options[:as] || ActiveModel::Naming.singular(object)
          apply_form_for_options!(record_or_name_or_array, options)
          args.unshift object
        else
          object = record_or_name_or_array
          object_name = options[:as] || ActiveModel::Naming.singular(object)
          apply_form_for_options!([object], options)
          args.unshift object
        end

### THE ONLY PART THAT NEEDS TO BE CHANGED BY SCAFFOLD360
        # (options[:html] ||= {})[:remote] = true if options.delete(:remote)
        if (ro = options.delete(:remote))
          (options[:html] ||= {})[:remote] = ro
        end
###

        output = form_tag(options.delete(:url) || {}, options.delete(:html) || {})
        output << fields_for(object_name, *(args << options), &proc)
        output.safe_concat('</form>')                
      end
    end    
  end    
end


# register new mime type
Mime::Type.register_alias "text/html", :htmlf

# use html partials when responding to htmlf requests
module ActionView
  class LookupContext #:nodoc:
    module Details
      def formats=(value)
        value = nil    if value == [:"*/*"]
        value << :html if value == [:js] || value == [:htmlf]
        super(value)
      end
    end
  end
end
