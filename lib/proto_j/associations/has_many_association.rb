module ProtoJ
  module Associations
    class HasManyAssociation
      attr_reader :target

      def initialize(klass)
        @klass  = klass
        @target = []
        @proxy  = CollectionProxy.new(self)
      end

      def reader
        @proxy
      end

      def concat(*records)
        records = records.flatten

        records.each do |record|
          unless record.is_a?(@klass)
            raise ::ProtoJ::Exception::TypeMismatch.new("require #{@klass}, but got #{record.class}")
          end
        end

        @target.concat(records)
      end

      def new
        child = @klass.new
        @target << child
        child
      end

      def to_hash
        @target.collect { |t| t.to_hash }
      end

      def clear
        @target = []
        @proxy
      end

      def update(json=[])
        new_target = []

        if json.is_a?(Array)
          array = json
        else
          array = JSON.parse(json)
        end

        if array.is_a? Array
          array.each do |item|
            new_target << @klass.new(item)
          end

          @target = new_target
        end

        @target
      end
    end
  end
end
