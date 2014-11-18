module Netverify
  class Validation < ActiveRecord::Base
    SUCCESS_STATES = %w(APPROVED_VERIFIED)
    FAILURE_STATES  = %w(DENIED_FRAUD DENIED_UNSUPPORTED_ID_TYPE
                         DENIED_UNSUPPORTED_ID_COUNTRY DENIED_NAME_MISMATCH
                         ERROR_NOT_READABLE_ID NO_ID_UPLOADED FAILURE)

    validates :jumio_id_scan_reference, presence: true
    validates :merchant_id_scan_reference, presence: true
    validates :validatable, presence: true

    serialize :error_types,          Hash
    serialize :images,               Hash
    serialize :personal_information, Hash

    belongs_to :validatable, polymorphic: true

    after_save :run_state_callback, if: :state_changed?

    # Check the verification and returns its status as Symbol
    # (:success / :fail / :pending)
    def verification_state
      if state.in?(SUCCESS_STATES)
        return :success
      elsif state.in?(FAILURE_STATES)
        return :fail
      end
      :pending
    end

    private

    def run_state_callback
      validatable.run_state_changed_callback
    end

    def state_changed?
      changed_attributes.key?('state')
    end
  end
end
