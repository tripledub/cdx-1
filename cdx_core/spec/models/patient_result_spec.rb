require 'spec_helper'

describe PatientResult do
  let(:encounter)   { Encounter.make }
  let(:test_result) { MicroscopyResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'requested_microscopy' }

  context "validations" do
    it { should belong_to(:encounter) }
    it { should belong_to(:feedback_message) }
  end

  context 'when status is rejected' do
    it 'should not validate if comment is empty' do
      test_result.result_status = 'rejected'
      test_result.comment = ' '
      expect(test_result).to_not be_valid
    end

    it 'should validate if comment has content' do
      test_result.result_status = 'rejected'
      test_result.comment = 'For whom the bell tolls'
      expect(test_result).to be_valid
    end
  end

  context 'after_save' do
    it 'should update status' do
      expect(TestOrders::Status).to receive(:update_status).with(test_result.encounter)

      test_result.save
    end

    describe 'change status' do
      it 'should be set to new when result is created' do
        expect(test_result.result_status).to eq('new')
      end

      it 'should be set to sample collected when result has sample id assigned' do
        test_result.update_attribute(:serial_number, 'some sample id')

        expect(test_result.result_status).to eq('sample_collected')
      end

      context 'if status is updated' do
        it 'should set completed_at to current time if status is completed' do
          test_result.update_attribute(:result_status, 'completed')

          expect(test_result.completed_at).to be
        end

        it 'should not update completed_at' do
          test_result.update_attribute(:result_status, 'rejected')

          expect(test_result.completed_at).to_not be
        end
      end
    end
  end

  describe 'turnaround time' do
    context 'when the test is incomplete' do
      it 'says incomplete' do
        expect(test_result.turnaround).to eq(I18n.t('patient_result.incomplete'))
      end
    end

    context 'when the test is closed' do
      it 'gives the turnaround time in words' do
        test_result.update_attribute(:result_status, 'completed')
        test_result.reload

        expect(test_result.turnaround).to include('3 days')
      end
    end
  end

  describe 'test_name' do
    context 'when result is microscopy' do
      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Microscopy')
      end
    end

    context 'when result is culture' do
      let(:test_result) { CultureResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'culture_cformat_liquid' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Culture')
      end
    end

    context 'when result is xpert' do
      let(:test_result) { XpertResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'requested_xpertmtb' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Xpert')
      end
    end

    context 'when result is dst' do
      let(:test_result) { DstLpaResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'drugsusceptibility1line_cformat_liquid' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Drug susceptibility')
      end
    end

    context 'when result is lpa' do
      let(:test_result) { DstLpaResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'lineprobe1_cformat_solid' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Line probe assay')
      end
    end

    context 'when result is liquid' do
      let(:test_result) { CultureResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'culture_cformat_liquid' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Liquid')
      end
    end

    context 'when result is solid' do
      let(:test_result) { DstLpaResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'lineprobe1_cformat_solid' }

      it 'should return microscopy as name' do
        expect(test_result.test_name).to include('Solid')
      end
    end
  end
end
