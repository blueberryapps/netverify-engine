module Netverify
  class IframeResponseFetcher

    def initialize(params = {})
      @params = params
      @validation = find_stored_validation
    end

    def fetch!
      @validation.state = if @params[:idScanStatus] == 'SUCCESS'
                            nil
                          elsif @params[:idScanStatus] == 'ERROR'
                            'ERROR'
                          end
      @validation.save
    end

    private

    def find_stored_validation
      Validation.find_by!(
        merchant_id_scan_reference: @params['merchantIdScanReference'],
        jumio_id_scan_reference: @params['jumioIdScanReference']
      )
    end
  end
end
