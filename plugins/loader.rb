# frozen_string_literal: true

require_relative 'base'

module Plugins
  # Loads required plugin
  class Loader
    def initialize
      @plugins = {}
    end

    def load_plugins!(requested_plugins)
      requested_plugins.each do |namespace, plugins|
        plugins.each do |plugin_name, _|
          get(namespace, plugin_name)
        rescue Plugins::PluginError => e
          log e.message
          exit 1
        end
      end
    end

    def get(namespace, plugin_name)
      plugins[plugin_name] ||= load!(namespace, plugin_name)
    end

    private

    def load!(namespace, plugin_name)
      require_relative "#{namespace}/#{plugin_name}_plugin.rb"

      plugin_class_name = class_name(namespace, plugin_name)

      Object.const_get(plugin_class_name).new
    rescue LoadError
      raise PluginError, "Plugin #{plugin_name} does not exist"
    rescue NameError
      raise PluginError, "Class #{plugin_class_name} was not found"
    rescue StandardError => e
      raise PluginError, "Unhandled exception: #{e.message}"
    end

    def class_name(namespace, plugin_name)
      plugin_class_name = snake_case_to_camel_case("#{plugin_name}_plugin")
      namespace = snake_case_to_camel_case(namespace)

      "#{class_module}::#{namespace}::#{plugin_class_name}"
    end

    def snake_case_to_camel_case(str)
      str.to_s.split('_').collect(&:capitalize).join
    end

    def class_module
      self.class.to_s.split('::').first
    end

    attr_reader :plugins
  end
end
