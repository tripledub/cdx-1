require 'spec_helper'

describe PatientResult do
  let(:test_result)         { MicroscopyResult.make }

  context "validations" do
    it { should belong_to(:requested_test) }
  end

  context 'after_save' do
    it 'should update status' do
      expect(TestStatus).to receive(:change_status).with(test_result)

      test_result.save
    end
  end
end
