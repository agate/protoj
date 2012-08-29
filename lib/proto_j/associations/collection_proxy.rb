module ProtoJ
  module Associations
    class CollectionProxy
      instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to/ }

      delegate :target, :concat, :new, :to_hash, :clear, :update, :to => :@association

      def initialize(association)
        @association = association
      end

      def ===(other)
        other === target
      end

      def to_ary
        target.dup
      end
      alias_method :to_a, :to_ary

      def <<(*records)
        @association.concat(records) && self
      end
      alias_method :push, :<<

      def method_missing(method, *args, &block)
        target.send(method, *args, &block)
      end
    end
  end
end
