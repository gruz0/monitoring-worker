# frozen_string_literal: true

def plugin_namespace(klass)
  klass.name.split('::')[1].downcase
end
