module Netverify
  class MultiDocumentInitiator
    include Engine.routes.url_helpers

    URL          = 'https://netverify.com'
    INITIATE_URI = '/api/netverify/v2/createDocumentAcquisition'

    def initialize(opts = {})
      @opts ||= OpenStruct.new
      opts.each do |k, v|
        @opts[k.to_sym] = v if valid_config_keys.include? k.to_sym
      end
      merge_default_params!
    end

    def perform_initiation!
      connection = Faraday.new(url: URL)
      connection.basic_auth(Netverify.config.api_token,
                            Netverify.config.api_secret)
      response = connection.post do |req|
        req.url INITIATE_URI
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept']       = 'application/json'
        req.headers['User-Agent']   = user_agent
        req.body                    = api_hash.to_json
      end

      JSON.parse(response.body)
    end

    private

    def required_keys
      [:success_url, :error_url, :merchant_scan_reference, :customer_id,
       :document_type]
    end

    def optional_keys
      [:authorization_token_lifetime, :merchant_reporting_criteria,
       :callback_url, :client_ip]
    end

    def valid_config_keys
      required_keys + optional_keys
    end

    def missing_required_keys
      required_keys - @opts.marshal_dump.keys
    end

    def merge_default_params!
      [:document_type, :error_url, :success_url, :merchant_scan_reference,
       :customer_id].each do |symbol|
        if @opts[symbol].blank?
          @opts[symbol] = default_options[symbol]
        end
      end
    end

    def default_options
      {
        success_url:             documents_success_url(
                                   host: Netverify.config.host),
        error_url:               documents_error_url(
                                   host: Netverify.config.host),
        callback_url:            documents_callback_url(
                                   host: Netverify.config.host),
        merchant_scan_reference: UUID.new.generate
      }
    end

    def user_agent
      "#{Netverify.config.company_name} "\
      "#{Netverify.config.app_name}/#{Netverify.config.app_version}"
    end

    def api_hash
      @opts.marshal_dump.
        map { |key, value| [key.to_s.camelize(:lower), value] }.
        to_h.
        tap { |hash| hash['customerID'] = hash.delete('customerId') }
    end
  end
end
