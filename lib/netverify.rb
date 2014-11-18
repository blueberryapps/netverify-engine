require 'netverify/engine'

require 'faraday'
require 'yaml'
require 'ostruct'

if defined?(::Rails) && ::Rails::VERSION::MAJOR >= 3
  Gem.find_files('netverify/**/*.rb').each { |path| require path }
end

module Netverify
  def self.configure_from_rails
    path = ::Rails.root.join('config', 'netverify.yml')
    configure_from_yaml(path)
  end

  def self.configure_from_yaml(yaml_path)
    config = YAML.load_file(yaml_path)[Rails.env]
    configure(config)
    unless configuration_complete?
      raise Netverify::IncompleteConfig,
            'Required keys must be specified' \
            " - missing: #{missing_config_keys.inspect}"
    end
  rescue Errno::ENOENT
    raise Netverify::ConfigNotFound
  rescue Psych::SyntaxError
    raise Netverify::BadConfigException
  end

  class << self
    attr_reader :config, :callback_urls
  end

  def self.configure(opts = {})
    @config ||= OpenStruct.new
    opts.except(:callback_urls).each do |key, val|
      @config[key.to_sym] = val if valid_config_keys.include? key.to_sym
    end

    @callback_urls ||= OpenStruct.new
    opts['callback_urls'].each do |key, val|
      @callback_urls[key.to_sym] = val
    end
  end

  private

  def self.required_config_keys
    %i(company_name app_name app_version api_token api_secret)
  end

  def self.optional_config_keys
    %i(callback_url host)
  end

  def self.valid_config_keys
    required_config_keys + optional_config_keys
  end

  def self.configuration_complete?
    missing_config_keys.empty?
  end

  def self.missing_config_keys
    required_config_keys - config.marshal_dump.keys
  end
end
