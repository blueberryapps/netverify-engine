module Netverify
  describe Validation do
    describe '#verification_state' do
      it 'should return true on approved status' do
        v = FactoryGirl.create :validation, state: 'APPROVED_VERIFIED'

        expect(v.verification_state).to eq :success
      end

      it 'should return false on error status' do
        v = FactoryGirl.create :validation, state: 'DENIED_FRAUD'

        expect(v.verification_state).to eq :fail
      end

      it 'should return :pending on undecided approvement' do
        v = FactoryGirl.create :validation, state: nil

        expect(v.verification_state).to eq :pending
      end

    end
  end
end
