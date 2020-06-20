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

domain            = Settings.domain
requested_plugins = Settings.plugins
loader            = Plugins::Loader.new
message_formatter = MessageFormatter.new

issues = {}

loader.load_plugins!(requested_plugins)

domain = loader.get(:generic, :domain_detector).call(domain)
scheme = loader.get(:generic, :scheme_detector).call(domain)

opts = {
  scheme: scheme,
  domain: domain,
  host: "#{scheme}://#{domain}"
}

requested_plugins.each do |namespace, plugins|
  issues[namespace] = {}

  plugins.each do |plugin_name|
    issues[namespace][plugin_name] = []

    plugin = loader.get(namespace, plugin_name)

    result = plugin.call(opts)

    message = message_formatter.call(plugin: plugin, domain_name: domain, result: result)

    log message

    issues[namespace][plugin_name] << { domain => result.description } if result.failure?
  end
end

i = {}

issues.each do |namespace, plugins|
  plugins = plugins.delete_if { |_, v| v.size.zero? }

  next if plugins.empty?

  i[namespace] = plugins
end

if i.empty?
  log 'No issues found'

  exit
end

log 'Detected issues:'
log JSON.pretty_generate(i)

abort
