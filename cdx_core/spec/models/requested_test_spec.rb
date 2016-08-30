require 'spec_helper'

RSpec.describe RequestedTest, type: :model do
  it { should have_one(:xpert_result) }
  it { should have_one(:microscopy_result) }
  it { should have_one(:dst_lpa_result) }
  it { should have_one(:culture_result) }

  describe 'validates fields' do
    it 'cannot create for missing fields' do
      requested_test = RequestedTest.create
      expect(requested_test).to_not be_valid
    end

    it 'can create requested test' do
      requested_test = RequestedTest.make
      expect(requested_test).to be_valid
    end

    it 'cannot create for missing name field' do
      requested_test = RequestedTest.make_unsaved(name: nil)
      expect(requested_test).to_not be_valid
    end

    context 'when status is rejected' do
      it 'should not validate if comment is empty' do
        requested_test        =  RequestedTest.make
        requested_test.status = :rejected
        requested_test.comment = ' '
        expect(requested_test).to_not be_valid
      end

      it 'should validate if comment has content' do
        requested_test = RequestedTest.make
        requested_test.status = :rejected
        requested_test.comment = 'For whom the bell tolls'
        expect(requested_test).to be_valid
      end
    end
  end

  describe 'validate soft delete' do
    it 'soft deletes a requested test' do
      requested_test = RequestedTest.make
      requested_test.destroy
      deleted_test_id = RequestedTest.where(id: requested_test.id).pluck(:id)
      expect(deleted_test_id).to eq([])
    end

    it 'soft deletes a requested test and verfiy requested test still exists' do
      requested_test = RequestedTest.make
      requested_test.destroy
      deleted_requested_test_id = RequestedTest.with_deleted
                                               .where(id: requested_test.id)
                                               .pluck(:id)
      expect(deleted_requested_test_id).to eq([requested_test.id])
    end
  end

  describe 'show_dst_warning' do
    context 'when dst and culture test are requested' do
      it 'should return true if both are not present' do
        RequestedTest.make name: 'culture'
        RequestedTest.make name: 'dst'

        expect(described_class.show_dst_warning).to eq(true)
      end

      it 'should return false if any of them are present' do
        expect(described_class.show_dst_warning).to eq(false)
      end
    end

    context 'when dst and culture test are notrequested' do
      it 'should return false' do
        RequestedTest.make name: 'microscopy'

        expect(described_class.show_dst_warning).to eq(false)
      end
    end
  end

  describe 'result_type' do
    let(:encounter) { Encounter.make }

    context 'Culture result' do
      let(:culture_result) { RequestedTest.make(encounter: encounter, name: 'culturehiv') }

      it 'should return Culture as result type' do
        expect(culture_result.result_type).to eq('Culture')
      end
    end

    context 'Xpert result' do
      let(:xpert_result) { RequestedTest.make(encounter: encounter, name: 'xpertmtb') }

      it 'should return Xpert as result type' do
        expect(xpert_result.result_type).to eq('Xpert')
      end
    end

    context 'Microscopy result' do
      let(:microscopy_result) { RequestedTest.make(encounter: encounter, name: 'microscopyhiv') }

      it 'should return Microscopy as result type' do
        expect(microscopy_result.result_type).to eq('Microscopy')
      end
    end

    context 'DST/LPA result' do
      let(:dst_lpa_result) { RequestedTest.make(encounter: encounter, name: 'dstebola') }

      it 'should return Culture as result type' do
        expect(dst_lpa_result.result_type).to eq('Dst/Lpa')
      end
    end

    context 'Drug susceptibility result' do
      let(:dst_lpa_result) { RequestedTest.make(encounter: encounter, name: 'drugsusceptibility2line_cformat_solid') }

      it 'should return Culture as result type' do
        expect(dst_lpa_result.result_type).to eq('Dst/Lpa')
      end
    end
  end

  describe 'turnaround time' do
    let!(:requested_test) { RequestedTest.make completed_at: nil }
    context 'when the test is incomplete' do
      it 'says incomplete' do
        expect(requested_test.turnaround).to eq(I18n.t('requested_test.incomplete'))
      end
    end

    context 'when the test is complete' do
      it 'gives the turnaround time in words' do
        Timecop.travel(requested_test.created_at + 3.days)
        requested_test.update_attribute(:status, 'completed')
        expect(requested_test.turnaround).to eq('3 days')
      end
    end
  end
end
