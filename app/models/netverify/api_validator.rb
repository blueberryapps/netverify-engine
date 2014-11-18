require 'ostruct'

module Netverify
  class ApiValidator
    include Engine.routes.url_helpers

    attr_accessor :opts, :verifiable

    URL = 'https://netverify.com'
    PERFORM_URI = '/api/netverify/v2/performNetverify'

    def initialize(verifiable_instance, opts = {})
      @verifiable = verifiable_instance
      @opts ||= OpenStruct.new
      opts.each do |k, v|
        @opts[k.to_sym] = v if valid_config_keys.include? k.to_sym
      end
      merge_default_params!
    end

    def perform!
      check_primary_key!
      check_required_keys!
      Rails.logger.warn @opts.keys.inspect
      response = initiate_verification!
      if response.status == 200
        v = Validation.new(validatable:                @verifiable,
                           jumio_id_scan_reference:    response_body(response)['jumioIdScanReference'],
                           merchant_id_scan_reference: @opts.merchant_id_scan_reference,
                           auth_type:                  'api')
        v.save && v
      else
        raise UnsuccessfulValidationRequest,
              'Netverify returned HTTP status ' \
              "#{response.status} + #{response.body}"
      end
    end

    private

    def initiate_verification!
      connection = Faraday.new(url: URL)

      connection.basic_auth(
        Netverify.config.api_token,
        Netverify.config.api_secret
      )

      connection.post do |req|
        req.url PERFORM_URI
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['User-Agent'] = user_agent
        req.body = api_hash.to_json
      end
    end

    def check_primary_key!
      unless @verifiable.class.try(:primary_key).present?
        raise ArgumentError, 'Verifiable object must have primary_key value set'
      end
    end

    def check_required_keys!
      unless missing_required_keys.empty?
        raise ArgumentError,
              "Missing required fields: #{missing_required_keys.inspect}"
      end
    end

    def required_keys
      %i(merchant_id_scan_reference frontside_image)
    end

    def optional_keys
      %i(frontside_image_mime_type enabled_fields merchant_reporting_criteria
         customer_id callback_url first_name last_name country us_state expiry
         number id_type dob backside_image backside_image_mime_type
         callback_granularity personal_number mrz_check additional_information
         face_image face_image_mime_type)
    end

    def api_hash
      @opts.marshal_dump.map { |k, v| [k.to_s.camelize(:lower), v] }.to_h
    end

    def valid_config_keys
      required_keys + optional_keys
    end

    def missing_required_keys
      required_keys - @opts.marshal_dump.keys
    end

    def user_agent
      "#{Netverify.config.company_name} "\
      "#{Netverify.config.app_name}/#{Netverify.config.app_version}"
    end

    def response_body(response)
      JSON.parse(response.body)
    end

    def merge_default_params!
      %i(merchant_id_scan_reference callback_url).each do |symbol|
        if @opts[symbol].blank?
          @opts[symbol] = default_options[symbol]
        end
      end
    end

    def default_options
      {
        # well, this is ugly
        callback_url: validations_callback_url(host: Netverify.config.host),
        merchant_id_scan_reference: UUID.new.generate
      }
    end
  end
end
