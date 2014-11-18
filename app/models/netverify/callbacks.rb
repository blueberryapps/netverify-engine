module Netverify
  module Callbacks
    extend ActiveSupport::Concern

    included do
      define_callbacks :netverify_state_changed

      def run_state_changed_callback
        run_callbacks :netverify_state_changed
      end

      def self.after_netverify_state_changed(func)
        set_callback :netverify_state_changed, :after, func
      end
    end

  end
end
