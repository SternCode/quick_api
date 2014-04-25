module QuickApi
  module Mongoid
    extend ActiveSupport::Concern

    included do
      class_attribute :quick_api_attributes
      class_attribute :quick_api_methods
      class_attribute :quick_api_has_many
      class_attribute :quick_api_belongs_to
      class_attribute :quick_api_has_one
      class_attribute :quick_api_has_and_belongs_to_many
      class_attribute :quick_api_embeds_many
      class_attribute :quick_api_embedded_in
      class_attribute :quick_api_embeds_one

    end

    module ClassMethods
      ##
      # This helper is included to the model to say witch fields/methods want to include to the to_api helper
      # @example Use example
      #   api_attr_accessible :first_name, :last_name => 
      #   {
      #     "first_name": "Name", 
      #     "last_name": "Surname"
      #   }
      def quick_api_attrributes(*names);
        self.quick_api_attributes = names
      end

      def quick_api_has_many(*relations)
        self.quick_api_has_many = relations
      end

      def quick_api_belongs_to(*relations)
        self.quick_api_belongs_to = relations
      end

      def quick_api_has_one(*relations)
        self.quick_api_has_one = relations
      end

      def quick_api_has_and_belongs_to_many(*relations)
        self.quick_api_has_and_belongs_to_many = relations
      end

      def quick_api_embeds_many(*relations)
        self.quick_api_embeds_many = relations
      end

      def quick_api_embedded_in(*relations)
        self.quick_api_embedded_in = relations
      end

      def quick_api_embeds_one(*relations)
        self.quick_api_embeds_one = relations
      end

      def quick_api_methods(*methods)
        self.quick_api_methods = methods
      end

    end

    ##
    # This method is included directly to the Model that includes this Concern. The principal function of 
    # this is to facilitate the API JSON construction with a bunch of helpers for the Model.
    #
    # In the model each simbol included in the :api_attr_accessible will be included at the top of the JSON
    #
    # @example Example of :fields
    #   user.to_api(fields: [:email, :full_name]) => {"email": "test_email@gmail.com", "full_name": "Name Surname"}
    # @example Example of :has_many, :belongs_to and :added
    #   user.to_api(has_many: [:pots], belongs_to: [:city], added: [citizens: (user.city.users.count)]) => 
    #   {
    #     "first_name": "Name", 
    #     "last_name": "Surname", 
    #     "posts": [{post.to_api}, {post.to_api}], 
    #     "city": {city.to_api}, 
    #     "citizens": 100
    #   }
    #
    # When calling then #to_api you can pass some optional params to modify the JOSN
    # @param [Hash] options The options to modify the JOSN
    # @param [Hash] result A possible JSON you can user for base
    # @option options [Array] :fields OVERRIDE the default fields of the :api_attr_accessible that you may define
    # @option options [Array] :has_many It calls the #to_api for each item in the array and builds a JSON Array for this objects inside a plural element of the :has_many item
    # @option options [Array] :belongs_to It calls the #to_api to each elemen related and puts the result JOSN inside a singula name of the :belongs_to
    # @option options [Array] :added It adds each pair of key/values to the result JSON
    def to_api(options = {}, result = {})
      if options[:fields]
        api_fields = options[:fields]
      else
        api_fields = self.quick_api_attributes.nil? ? [] : self.quick_api_attributes
      end
      api_fields.each do |api_field|
        begin
          if (self.send(api_field)).class == Paperclip::Attachment
            picture_styles = []
            self.send(api_field).styles.each {|style| picture_styles << style[0]}
            result[api_field] = {original: "http://#{ActionMailer::Base.default_url_options[:host]}#{self.send(api_field).url}",
                                 styles: picture_styles}
          else
            result[api_field] = self.send(api_field)
          end
        rescue
          result[api_field] = self.send(api_field)
        end
      end

      if self.quick_api_methods
        result = api_method_options(result, self.quick_api_methods)
      end 

      if self.quick_api_has_many
        result = api_many_options(result, self.quick_api_has_many)
      end  

      if self.quick_api_belongs_to
        result = api_belongs_or_one_options(result, self.quick_api_belongs_to)
      end  

      if self.quick_api_has_one
        result = api_belong_or_one_options(result, self.quick_api_has_one)
      end

      if self.quick_api_has_and_belongs_to_many
        result = api_many_options(result, self.quick_api_has_and_belongs_to_many)
      end

      if self.quick_api_embeds_many
        result = api_many_options(result, self.quick_api_embeds_many)
      end

      if self.quick_api_embedded_in
        result = api_belongs_or_one_options(result, self.quick_api_embedded_in)
      end

      if self.quick_api_embeds_one
        result = api_belongs_or_one_options(result, self.quick_api_embeds_one)
      end


      result = api_set_options(result, options)

      return result
    end

    private

    def api_method_options(result, options)
      options.each do |method|
        #TODO doc
        result.merge! self.send(method)
      end
      return result 
    end

    def api_set_options(result, options)
      result = api_added(result, options[:added]) if options[:added]

      return result
    end

    def api_many_options(result, many)
      many.each do |model|
        resources = eval(model.to_s.underscore.pluralize)
        result_api_resources = []
        resources.each do |resource|
          result_api_resources << resource.to_api
        end
        result[model.to_s.underscore.pluralize] = result_api_resources
      end

      return result
    end

    def api_belong_or_one_options(result, one)
      one.each do |model|
        resource = eval(model.to_s.singularize.camelize.underscore)
        result[model.to_s.singularize.camelize.underscore] = resource.try(:to_api)
      end
      return result
    end

    def api_push_values(result, values)
      values.each do |field|
        field.each do |sub_field|
          result[sub_field[0]] = sub_field[1] unless sub_field.empty?
        end
      end

      return result
    end

    def api_added(result, added)
      added.each do |field|
        field.each do |sub_field|
          result[sub_field[0]] = sub_field[1] unless sub_field.empty?
        end
      end

      return result
    end
