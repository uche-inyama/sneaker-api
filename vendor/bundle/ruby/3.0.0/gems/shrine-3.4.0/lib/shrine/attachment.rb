# frozen_string_literal: true

class Shrine
  # Core class that provides an attachment interface for a specified attribute
  # name, which can be added to model/entity classes. The model/entity plugins
  # define the main interface, which delegates to a Shrine::Attacher object.
  class Attachment < Module
    @shrine_class = ::Shrine

    module ClassMethods
      # Returns the Shrine class that this attachment class is
      # namespaced under.
      attr_accessor :shrine_class

      # Since Attachment is anonymously subclassed when Shrine is subclassed,
      # and then assigned to a constant of the Shrine subclass, make inspect
      # reflect the likely name for the class.
      def inspect
        "#{shrine_class.inspect}::Attachment"
      end

      # Shorthand for `Attachment.new`.
      #
      #   Shrine::Attachment[:image]
      def [](*args, **options)
        new(*args, **options)
      end
    end

    module InstanceMethods
      # Instantiates an attachment module for a given attribute name, which
      # can then be included to a model class. Second argument will be passed
      # to an attacher module.
      def initialize(name, **options)
        @name    = name.to_sym
        @options = options
      end

      # Returns name of the attachment this module provides.
      def attachment_name
        @name
      end

      # Returns options that are to be passed to the Attacher.
      def options
        @options
      end

      # Returns class name with attachment name included.
      #
      #     Shrine::Attachment.new(:image).to_s #=> "#<Shrine::Attachment(image)>"
      def inspect
        "#<#{self.class.inspect}(#{@name})>"
      end
      alias to_s inspect

      # Returns the Shrine class that this attachment's class is namespaced
      # under.
      def shrine_class
        self.class.shrine_class
      end
    end

    extend ClassMethods
    include InstanceMethods
  end
end
