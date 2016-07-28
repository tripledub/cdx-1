require 'spec_helper'

RSpec.describe RequestedTest, :type => :model do
  it { should have_one(:xpert_result) }
  it { should have_one(:microscopy_result) }
  it { should have_one(:dst_lpa_result) }
  it { should have_one(:culture_result) }

  context "validates fields" do
    it "cannot create for missing fields" do
      requested_test = RequestedTest.create
      expect(requested_test).to_not be_valid
    end

    it "can create requested test" do
      requested_test =  RequestedTest.make
      expect(requested_test).to be_valid
    end

    it "cannot create for missing name field" do
      requested_test =  RequestedTest.make
      requested_test.name=nil
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
        requested_test        =  RequestedTest.make
        requested_test.status = :rejected
        requested_test.comment = 'For whom the bell tolls'

        expect(requested_test).to be_valid
      end
    end
  end

  context "validate soft delete" do
    it "soft deletes a requested test" do
      requested_test =  RequestedTest.make
      requested_test.destroy
      deleted_requested_test_id = RequestedTest.where(id: requested_test.id).pluck(:id)
      expect(deleted_requested_test_id).to eq([])
    end

    it "soft deletes a requested test and verfiy requested test still exists" do
      requested_test =  RequestedTest.make
      requested_test.destroy
      deleted_requested_test_id = RequestedTest.with_deleted.where(id: requested_test.id).pluck(:id)
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
end
