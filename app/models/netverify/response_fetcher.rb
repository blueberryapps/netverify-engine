module Netverify
  class ResponseFetcher

    def initialize(params = {})
      @params = params
      @validation = find_stored_validation
    end

    def fetch!
      prepare_fields
      fetch_personal_info_fields
      fetch_image_fields
      fetch_reject_reason_fields
      fetch_additional_info
      @validation.save
    end

    private

    def prepare_fields
      @validation.personal_information ||= {}
      @validation.images ||= {}
    end

    def find_stored_validation
      Validation.find_by(
        merchant_id_scan_reference: @params['merchantIdScanReference'],
        jumio_id_scan_reference: @params['jumioIdScanReference']
      )
    end

    def fetch_additional_info
      @validation.state = @params['verificationStatus']
    end

    def fetch_personal_info_fields
      %w(idCountry idType idFirstName idLastName idDob idExpiry idNumber
         idUsState personalNumber).each do |field|
        if @params[field].present?
          @validation.personal_information[field] = @params[field]
        end
      end
    end

    def fetch_image_fields
      %w(idScanImage idScanImageBackside).each do |field|
        if @params[field].present?
          @validation.images[field] = @params[field]
        end
      end
    end

    def fetch_reject_reason_fields
      if @params['rejectReason'].present?
        errors = JSON.parse(@params['rejectReason'])
        @validation.error_types = errors
      end
    end
  end
end
