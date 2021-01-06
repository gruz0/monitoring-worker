# frozen_string_literal: true

require 'net/http'
require 'yaml'
require 'json'
require 'config'
require 'dry/validation'

require_relative 'lib/config'
require_relative 'lib/http_client'
require_relative 'lib/result'
require_relative 'lib/message_formatter'
require_relative 'plugins/loader'

def log(message = '')
  return unless Settings.key?(:verbose) && Settings.verbose == 1

  puts message
end

def select_enabled_plugins(selected_plugins)
  enabled_plugins = {}

  selected_plugins.each do |namespace, plugins|
    result = plugins.map { |plugin, enabled| plugin if enabled == 1 }.flatten

    next if result.empty?

    enabled_plugins[namespace] = result
  end

  enabled_plugins
end

domain_name       = Settings.domain
selected_plugins  = Settings.plugins
loader            = Plugins::Loader.new
message_formatter = MessageFormatter.new

enabled_plugins = select_enabled_plugins(selected_plugins)

loader.load_plugins!(enabled_plugins)

domain_detector = loader.get(:generic, :domain_detector).call(domain_name)

if domain_detector.failure?
  log "[#{domain_detector.plugin_name}] #{domain_detector.value}"

  exit 1
end

# rubocop:disable Style/AsciiComments
# NOTE: По идее здесь сейчас может быть ситуация, когда сайт на домене не работает,
# чтобы определить корректную схему, но нам надо проверить работоспособность домена в части DNS,
# например, наличие A-записей, либо же проверить просроченность домена.
#
# Наверно есть смысл разделить проверки по уровням, либо в зависимости от того,
# что если домен просрочен, то мы ничего с ним уже не делаем. Либо если нет A-записи,
# то мы тоже ничего не делаем дальше.
#
# Или же надо получать состояние домена из базы данных до запуска всех проверок
# и если он просрочен, то мы ничего не делаем вообще. И, кстати, получать информацию
# о домене из базы данных тоже можно плагином.
#
# Но с другой стороны, у нас воркер должен просто дёрнуть все проверки и отправить
# отчёты в АПИ о состоянии каждого плагина.
# rubocop:enable Style/AsciiComments

scheme_detector = loader.get(:generic, :scheme_detector).call(domain_detector.value)

if scheme_detector.failure?
  log "[#{scheme_detector.plugin_name}] #{scheme_detector.value}"

  exit 1
end

opts = {
  scheme: scheme_detector.value,
  domain: domain_detector.value,
  host: "#{scheme_detector.value}://#{domain_detector.value}"
}

issues = {}

enabled_plugins.each do |namespace, plugins|
  issues[namespace] = {}

  plugins.each do |plugin_name|
    issues[namespace][plugin_name] = []

    plugin = loader.get(namespace, plugin_name)

    result = plugin.call(opts)

    message = message_formatter.call(plugin: plugin, domain_name: domain_detector.value, result: result)

    log message

    issues[namespace][plugin_name] << { domain_detector.value => result.value } if result.failure?
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

exit 1
