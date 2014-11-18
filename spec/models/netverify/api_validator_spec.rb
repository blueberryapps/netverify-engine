require 'uuid'

describe Netverify::ApiValidator do

  let(:user_agent) do
    "#{Netverify.config.company_name} #{Netverify.config.app_name}/#{Netverify.config.app_version}"
  end
  let(:valid_params) { { merchant_id_scan_reference: 1, frontside_image: 'abcdefg', callback_url: 'http://dummy.dev/netverify/validations/callback' } }
  let(:valid_api_params) { { merchantIdScanReference: 1, frontsideImage: 'abcdefg', callbackUrl: 'http://dummy.dev/netverify/validations/callback' }.to_json }
  let(:valid_api_headers) { { :'Content-Type' => 'application/json', :'User-Agent' => user_agent, :'Accept' => 'application/json' } }
  let(:valid_response) { { jumioIdScanReference: '123456', timestamp: Time.now.strftime('%Y-%m-%dT%H:%M:%S.%LZ') }.to_json }

  before do
    address = Netverify::ApiValidator::URL + Netverify::ApiValidator::PERFORM_URI
    login_address = "https://#{Netverify.config.api_token}:#{Netverify.config.api_secret}@netverify.com#{Netverify::ApiValidator::PERFORM_URI}"

    stub_request(:any, address).to_return(status: 403)
    stub_request(:any, login_address).to_return(status: 403)
    stub_request(:post, login_address).with(body: valid_api_params, headers: valid_api_headers).to_return(status: 200, body: valid_response)
  end

  describe '#new' do
    it 'should assign a merchant id scan reference if not set' do
      validator = Netverify::ApiValidator.new(
        FactoryGirl.create(:user),
        frontside_image: valid_params[:frontside_image]
      )

      expect(validator.opts.merchant_id_scan_reference).to be_present
    end
  end

  describe '#perform!' do
    it 'should not raise an error if properly configured' do
      validator = Netverify::ApiValidator.new(FactoryGirl.create(:user), valid_params)
      expect { validator.perform! }.not_to raise_error
    end

    it 'should raise an error if one of required keys is missing' do
      validator = Netverify::ApiValidator.new(FactoryGirl.create(:user))
      expect { validator.perform! }.to raise_error
    end

    it 'should check if verifiable object is an object with primary_key method' do
      validator = Netverify::ApiValidator.new(Object.new, {})
      expect { validator.perform! }.to raise_error
    end

    it 'should send successful request to NetVerify API' do
      validator = Netverify::ApiValidator.new(FactoryGirl.create(:user), valid_params)
      validation = validator.perform!

      expect(validation).to be_a Netverify::Validation
      expect(validation.jumio_id_scan_reference).not_to be_nil
    end
  end
end
