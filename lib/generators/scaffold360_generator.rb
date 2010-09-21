# patch ScaffoldControllerGenerator to use custom path
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
module Rails
  module Generators
    class ScaffoldControllerGenerator
      def create_controller_files
        #source_paths.insert(0, "#{Rails.root}/lib/generators/scaffold360/templates") # HACK HACK HACK
        source_paths.insert(0, "#{File.dirname(__FILE__)}/templates") # HACK HACK HACK
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end
    end
  end
end

# patch ERB generator to use all our views
require 'rails/generators/erb/scaffold/scaffold_generator'
module Erb
  module Generators
    class ScaffoldGenerator < Base
      
      def copy_view_files
        views = available_views
        
        # treat index specially: create index.html.erb and index.js.erb
        if !options[:singleton]
          filename = ['index', format, handler].compact.join(".")
          template filename, File.join("app/views", controller_file_path, filename)

          filename = ['index', :js, handler].compact.join(".")
          template filename, File.join("app/views", controller_file_path, filename)
        end
        
        views.each do |view|
          filename = filename_with_extensions(view)
          template filename, File.join("app/views", controller_file_path, filename)
        end
        
        # also generate a css file for this model. Maybe this should be part of the StylesheetGenerator, but the filename is not available there
        template "model.css", "public/stylesheets/#{file_name.pluralize}.css" if behavior == :invoke
      end

      protected
        
        def available_views          
          #source_paths.insert(0, "#{Rails.root}/lib/generators/scaffold360/templates") # HACK HACK HACK          
          source_paths.insert(0, "#{File.dirname(__FILE__)}/templates") # HACK HACK HACK
          %w( edit new show  _index _edit _new _show  _collection _form _object _pagination)
        end
    end
  end
end

require 'rails/generators/rails/scaffold/scaffold_generator'
class Scaffold360Generator < Rails::Generators::ScaffoldGenerator
  #def self.source_root
  #  @source_root ||= File.expand_path('../templates', __FILE__)
  #end  
end
