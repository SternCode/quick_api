module QuickApi
  module Mongoid
    extend ActiveSupport::Concern

    included do
      # class_attribute :quick_api_methods
      class_attribute :q_api_attributes
      class_attribute :q_api_has_many
      class_attribute :q_api_belongs_to
      class_attribute :q_api_has_one
      class_attribute :q_api_has_and_belongs_to_many
      class_attribute :q_api_embeds_many
      class_attribute :q_api_embedded_in
      class_attribute :q_api_embeds_one
    end

    module ClassMethods

      def quick_api_attributes(*names)
        self.q_api_attributes = names
      end

      def quick_api_has_many(*relations)
        self.q_api_has_many = relations
      end

      def quick_api_belongs_to(*relations)
        self.q_api_belongs_to = relations
      end

      def quick_api_has_one(*relations)
        self.q_api_has_one = relations
      end

      def quick_api_has_and_belongs_to_many(*relations)
        self.q_api_has_and_belongs_to_many = relations
      end

      def quick_api_embeds_many(*relations)
        self.q_api_embeds_many = relations
      end

      def quick_api_embedded_in(*relations)
        self.q_api_embedded_in = relations
      end

      def quick_api_embeds_one(*relations)
        self.q_api_embeds_one = relations
      end

      # def quick_api_methods(*methods)
      #   self.quick_api_methods = methods
      # end

    end

    def to_api(options = {options: {relations: true}}, result = {})
      if options[:fields]
        api_fields = options[:fields]
      else
        api_fields = self.q_api_attributes.nil? ? [] : self.q_api_attributes
      end
      api_fields.each do |api_field|
        begin
          if (self.send(api_field)).class == Paperclip::Attachment
            picture_styles = []
            self.send(api_field).styles.each {|style| picture_styles << style[0]}
            result[api_field] = {original: "http://#{ActionMailer::Base.default_url_options[:host]}#{self.send(api_field).url}",
                                 styles: picture_styles}
          else
            begin
              result[api_field] = self.send(api_field)
            rescue
              raise "The field #{api_field} don't exist in this Model"
            end
          end
        rescue
          begin
            if (self.send(api_field)).class == ActiveSupport::TimeWithZone) or (self.send(api_field)).class == Date) or (self.send(api_field)).class == DateTime)
              result[api_field] = self.send(api_field).to_time.iso8601
            else
              result[api_field] = self.send(api_field)
            end
          rescue
            raise "The field #{api_field} don't exist in this Model"
          end
        end
      end

      # if self.quick_api_methods
      #   result = api_method_options(result, self.quick_api_methods)
      # end 

      if options[:options][:relations] == true
          result = api_many_options(result, self.q_api_has_many)                if self.q_api_has_many
          result = api_belongs_or_one_options(result, self.q_api_belongs_to)    if self.q_api_belongs_to
          result = api_belongs_or_one_options(result, self.q_api_has_one)       if self.q_api_has_one
          result = api_many_options(result, self.q_api_has_and_belongs_to_many) if self.q_api_has_and_belongs_to_many
          result = api_many_options(result, self.q_api_embeds_many)             if self.q_api_embeds_many
          result = api_belongs_or_one_options(result, self.q_api_embedded_in)   if self.q_api_embedded_in
          result = api_belongs_or_one_options(result, self.q_api_embeds_one)    if self.q_api_embeds_one
      end

      result = api_set_options(result, options)

      return result
    end

    private

    # def api_method_options(result, options)
    #   options.each do |method|
    #     #TODO doc
    #     result.merge! self.send(method)
    #   end
    #   return result 
    # end

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

    def api_belongs_or_one_options(result, one)
      one.each do |model|
        resource = eval(model.to_s.singularize.camelize.underscore)
        result[model.to_s.singularize.camelize.underscore] = resource.try(:to_api)
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
  end
end
