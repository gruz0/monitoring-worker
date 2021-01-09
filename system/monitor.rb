# frozen_string_literal: true

MONITOR_MESSAGE_FORMAT = '%s#%s called with args: %s in %d ms'

def event_attrs(event)
  payload = event.payload
  target  = payload[:target]
  method  = payload[:method]
  args    = payload[:args]
  time    = payload[:time]

  [target, method, args, time]
end

def log_plugin(event)
  lambda do
    target, method, args, time = event_attrs(event)

    Application[:logger].debug { format(MONITOR_MESSAGE_FORMAT, target, method, args, time) }
  end
end

def plugins_list
  Application.resolve('config').plugins.map do |namespace, plugins|
    plugins.keys.map { |plugin_name| "plugins.#{namespace}.#{plugin_name}_plugin" }
  end.flatten
end

plugins_list.each { |plugin| Application.monitor(plugin) { |event| log_plugin(event).call } }
