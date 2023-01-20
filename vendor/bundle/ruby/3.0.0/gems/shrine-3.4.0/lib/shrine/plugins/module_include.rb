# frozen_string_literal: true

Shrine.deprecation("The module_include plugin is deprecated and will be removed in Shrine 4. Override core classes directly instead.")

class Shrine
  module Plugins
    # Documentation can be found on https://shrinerb.com/docs/plugins/module_include
    module ModuleInclude
      module ClassMethods
        def attachment_module(mod = nil, &block)
          module_include(self::Attachment, mod, &block)
        end

        def attacher_module(mod = nil, &block)
          module_include(self::Attacher, mod, &block)
        end

        def file_module(mod = nil, &block)
          module_include(self::UploadedFile, mod, &block)
        end

        private

        def module_include(klass, mod, &block)
          mod ||= Module.new(&block)
          klass.include(mod)
        end
      end
    end

    register_plugin(:module_include, ModuleInclude)
  end
end
