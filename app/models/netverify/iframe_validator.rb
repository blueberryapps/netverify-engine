module Netverify
  class IframeValidator
    include Engine.routes.url_helpers

    URL = 'https://netverify.com'
    INITIATE_URI = '/api/netverify/v2/initiateNetverify'

    def initialize(verifiable_instance, opts = {})
      @verifiable = verifiable_instance
      @opts ||= OpenStruct.new
      opts.each { |k, v| @opts[k.to_sym] = v if valid_config_keys.include? k.to_sym }
      merge_default_params!
    end

    def perform_initiation!
      check_primary_key!
      check_required_keys!
      response = initiate_verification!
      if response.status == 200
        v = Validation.new(
          validatable:                @verifiable,
          jumio_id_scan_reference:    response_body(response)['jumioIdScanReference'],
          merchant_id_scan_reference: @opts.merchant_id_scan_reference,
          authorization_token:        response_body(response)['authorizationToken'],
          auth_type:                  'iframe')

        v.save && v
      else
        raise UnsuccessfulValidationRequest, "Netverify returned HTTP status #{response.status} + #{response.body}"
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
        req.url INITIATE_URI
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['User-Agent'] = user_agent
        req.body = api_hash.to_json
      end
    end

    def required_keys
      %i(merchant_id_scan_reference)
    end

    def optional_keys
      %i(success_url error_url enabled_fields authorization_token_lifetime
         merchant_reporting_criteria callback_url locale client_ip customer_id
         first_name last_name country us_state expiry number dob id_type
         personal_number mrz_check additional_information)
    end

    def merge_default_params!
      %i(merchant_id_scan_reference callback_url error_url success_url
         customer_id).each do |symbol|
        if @opts[symbol].blank?
          @opts[symbol] = default_options[symbol]
        end
      end
    end

    def default_options
      {
        # well, this is ugly
        callback_url: validations_callback_url(host: Netverify.config.host),
        error_url: validations_error_url(host: Netverify.config.host),
        success_url: validations_success_url(host: Netverify.config.host),
        merchant_id_scan_reference: UUID.new.generate,
        customer_id: UUID.new.generate
      }
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

    def api_hash
      @opts.marshal_dump.map { |k, v| [k.to_s.camelize(:lower), v] }.to_h
    end
  end
end
