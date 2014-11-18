require 'uuid'

module Netverify
  class Engine < ::Rails::Engine
    isolate_namespace Netverify

    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
      generate.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.assets.initialize_on_precompile = true
  end
end
