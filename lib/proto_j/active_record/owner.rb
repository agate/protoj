module ActiveJson
  module ActiveRecord::Owner
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def proto_j(key, options={})
        db_column      = options[:db_column] || "#{key}_json"
        settings_class = options[:class] || "#{key.to_s.classify}".constantize

        before_save do |m|
          attributes = {}
          attributes[db_column] = m.send(key).to_json
          m.assign_attributes(attributes, :without_protection => true)
        end

        define_method key do
          var_name = "@#{key}"
          settings = instance_variable_get(var_name)

          unless settings
            settings = settings_class.new(attributes[db_column.to_s])
            instance_variable_set(var_name, settings)
          end

          settings
        end
      end
    end
  end
end
