module ProtoJ
  class Base
    class << self
      def fields
        begin
          return class_variable_get("@@fields")
        rescue
          var = []
          class_variable_set("@@fields", var)
          return var
        end
      end

      def associations
        begin
          return class_variable_get("@@associations")
        rescue
          var = []
          class_variable_set("@@associations", var)
          return var
        end
      end

      def field(key, options={})
        fields << { key: key, options: options }

        define_method key do
          normalize_value(instance_variable_get("@#{key}"), options)
        end
        define_method "#{key}=" do |val|
          val = normalize_value(val, options)
          instance_variable_set("@#{key}", val)
        end
      end

      def has_one(key, options={})
        options[:class] ||= "#{self.name}::#{key.to_s.capitalize}".constantize
        associations << { key: key, options: options, type: :has_one, class: options[:class] }

        define_method key do
          instance_variable_get("@#{key}")
        end
        define_method "#{key}=" do |val|
          # TODO change to association exception class way
          raise 'Class Mismatch' unless val.is_a?(options[:class])
          instance_variable_set("@#{key}", val)
        end
      end

      def has_many(key, options={})
        options[:class] ||= "#{self.name}::#{key.to_s.singularize.capitalize}".constantize
        associations << { key: key, options: options, type: :has_many, class: options[:class] }

        define_method key do
          instance_variable_get("@#{key}").reader
        end
      end
    end

    def initialize(json={})
      if json.is_a?(Hash)
        hash = json
      else
        hash = JSON.parse(json) rescue {}
      end

      self.class.fields.each do |f|
        key = f[:key]
        instance_variable_set("@#{key}", hash[key.to_s])
      end

      self.class.associations.each do |a|
        key = a[:key]

        case a[:type].to_sym
        when :has_one
          instance_variable_set("@#{key}", a[:class].new(hash[key.to_s]))
        when :has_many
          instance_variable_set("@#{key}", Associations::HasManyAssociation.new(a[:class]))

          (hash[key.to_s] || []).each do |item|
            instance_variable_get("@#{key}").reader << a[:class].new(item)
          end
        end
      end
    end

    def update(json={})
      if json.is_a?(Hash)
        hash = json
      else
        hash = JSON.parse(json) rescue {}
      end

      self.class.fields.each do |f|
        key = f[:key].to_s
        if hash.has_key?(key)
          self.send("#{key}=", hash[key])
        end
      end

      self.class.associations.each do |a|
        key = a[:key].to_s

        if hash.has_key?(key)
          self.send(key).update(hash[key])
        end
      end
    end

    def to_json
      to_hash.to_json
    end

    def to_hash
      hash = {}

      self.class.fields.each do |f|
        hash[f[:key].to_s] = ::ProtoJ::Utils.to_sorted_hash(self.send(f[:key]))
      end

      self.class.associations.each do |a|
        hash[a[:key].to_s] = self.send(a[:key]).to_hash
      end

      Hash[hash.sort]
    end

    private

    def get(key)
      instance_variable_get("@#{key}")
    end

    def set(key, val)
      var = instance_variable_get("@#{key}")
      unless var
        var = klass.new(@hash[key.to_s])
        instance_variable_set("@#{key}", var)
      end
      var
    end

    def normalize_value(value, field_options)
      field_type = field_options[:type]

      if field_type
        case field_type.name
        when 'Array'
          case value
          when Array
          when String
            value = JSON.parse(value) rescue []
          else
            value = []
          end
        when 'Hash'
          case value
          when Hash
          when String
            value = JSON.parse(value) rescue {}
          else
            value = {}
          end
        end
      end

      return value
    end
  end
end
