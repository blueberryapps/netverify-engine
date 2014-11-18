require 'cgi'

module Netverify
  describe ValidationsController do
    routes { Netverify::Engine.routes }

    describe 'POST callback' do
      context 'successful validation' do
        let(:parameters) do
          {
            idExpiry: '2022-12-31',
            idType: 'PASSPORT',
            idDob: '1990-01-01',
            idCheckSignature: 'OK',
            idCheckDataPositions: 'OK',
            idCheckHologram: 'OK',
            idCheckMicroPrint: 'OK',
            idCheckDocumentValidation: 'OK',
            idCountry: 'USA',
            idScanSource: 'WEB_UPLOAD',
            idFirstName: 'Bob',
            idLastName: 'Bobby',
            verificationStatus: 'APPROVED_VERIFIED',
            jumioIdScanReference: '123456',
            personalNumber: 'N/A',
            merchantIdScanReference: '1',
            idCheckSecurityFeatures: 'OK',
            idCheckMRZcode: 'OK',
            idScanImage: 'https://netverify.com/recognition/v1/idscan/123456/front',
            callBackType: 'NETVERIFYID',
            clientIp: '123.123.123.123',
            idAddress: "{\"country\":\"USA\", \"state\":\"OH\"}",
            idScanStatus: 'SUCCESS',
            idNumber: 'P1234'
          }
        end

        it 'should return 200 on callback' do
          post :callback, parameters

          expect(response).to be_success
        end

      end

      context 'failed validation' do
        let(:parameters) do
          {
            idType: 'PASSPORT',
            idCheckSignature: 'N/A',
            rejectReason: "{ \"rejectReasonCode\":\"100\", \"rejectReasonDescription\": \"MANIPULATED_DOCUMENT\", " \
                          "\"rejectReasonDetails\": [{ \"detailsCode\": \"1001\", \"detailsDescription\": \"PHOTO\" }, "\
                          "{ \"detailsCode\": \"1004\", \"detailsDescription\": \"DOB\" }]}",
            idCheckDataPositions: 'N/A',
            idCheckHologram: 'N/A',
            idCheckMicroprint: 'N/A',
            idCheckDocumentValidation: 'N/A',
            idCountry: 'USA',
            idScanSource: 'WEB_UPLOAD',
            verificationStatus: 'DENIED_FRAUD',
            jumioIdScanReference: '123456',
            merchantIdScanReference: '1',
            idCheckSecurityFeatures: 'N/A',
            idCheckMRZCode: 'N/A',
            idScanImage: 'https://netverify.com/recognition/v1/idscan/123456/front',
            callBackType: 'NETVERIFYID',
            clientIp: '123.123.123.123',
            idScanStatus: 'ERROR'
          }
        end

        it 'should return 200 on errorred validation callback' do
          post :callback, parameters

          expect(response).to be_success
        end
      end
    end
  end
end
