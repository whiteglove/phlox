module ActiveResource #:nodoc:
  module Extend
    # OpenEMR API doesn't behave like a typical resource endpoints and can vary
    # based on the CRUD action, and requests can be a GET or POST (we prefer POST in this implementation).
    #
    # This module overrides the normal paths for ActiveResource and treats them as static (from site)
    # allowing you to still use normal ActiveResource custom_method type calls:
    #
    # e.g.  # POST /openemr/api/getpatientrecord
    #       post(:getpatientrecord, {:patientID => 2, :token => token})
    #
    module StaticPath

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          class << self
            alias_method_chain :element_path, :extension
            alias_method_chain :new_element_path, :extension
            alias_method_chain :collection_path, :extension
            alias_method_chain :custom_method_collection_url, :extension
          end
          alias_method_chain :custom_method_new_element_url, :extension
          alias_method_chain :custom_method_element_url, :extension
        end
      end

      module ClassMethods
        def element_path_with_extension(*args)
          Phlox::Base.site.path
        end
        def new_element_path_with_extension(*args)
          Phlox::Base.site.path
        end
        def collection_path_with_extension(*args)
          Phlox::Base.site.path
        end
        def custom_method_collection_url_with_extension(method_name, options={})
          prefix_options, query_options = split_options(options)
          "#{prefix(prefix_options)}#{method_name}#{query_string(query_options)}"
        end
      end

      private

      def custom_method_new_element_url_with_extension(method_name, options)
        "#{self.class.prefix(prefix_options)}#{method_name}#{self.class.__send__(:query_string, options)}"
      end

      def custom_method_element_url_with_extension(method_name, options)
        "#{self.class.prefix(prefix_options)}#{method_name}#{self.class.__send__(:query_string, options)}"
      end

    end
  end
end
