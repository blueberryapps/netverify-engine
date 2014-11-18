module Netverify
  class ValidationsController < ApplicationController
    layout false

    def callback
      ResponseFetcher.new(params).fetch!
      render nothing: true
    end

    def success
      IframeResponseFetcher.new(params).fetch!
    end

    def error
      IframeResponseFetcher.new(params).fetch!
    end
  end
end
