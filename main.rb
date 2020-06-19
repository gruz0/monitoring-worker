# frozen_string_literal: true

require 'net/http'
require 'yaml'
require 'json'
require 'config'
require 'dry/validation'

require_relative 'lib/config'
require_relative 'lib/result'
require_relative 'lib/message_formatter'
require_relative 'plugins/loader'

def log(message = '')
  return unless Settings.key?(:verbose) && Settings.verbose

  puts message
end

requested_plugins = Settings.plugins
loader            = Plugins::Loader.new
message_formatter = MessageFormatter.new

issues = {}

loader.load_plugins!(requested_plugins)

requested_plugins.each do |namespace, plugins|
  issues[namespace] = {}

  plugins.each do |plugin_name, domains|
    issues[namespace][plugin_name] = []

    plugin = loader.get(namespace, plugin_name)

    domains.each do |domain|
      result = plugin.call(domain)

      message = message_formatter.call(plugin: plugin, domain_name: domain, result: result)

      log message

      issues[namespace][plugin_name] << { domain => result.description } if result.failure?
    end
  end
end

issues.reject! do |_, r|
  m = r.reject do |_, d|
    d.size.zero?
  end

  m.size.zero?
end

if issues.empty?
  log 'No issues found'
else
  log 'Detected issues:'
  log JSON.pretty_generate(issues)

  abort
end
