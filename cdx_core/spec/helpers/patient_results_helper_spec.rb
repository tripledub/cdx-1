require 'spec_helper'

RSpec.describe PatientResultsHelper, type: :helper do
  let(:user) { User.make }
  let(:microscopy_result) { MicroscopyResult.make }

  describe 'show_approval_buttons?' do
    context 'with valid data' do
      before :each do
        Policy.stub(:can?).and_return(true)
        microscopy_result.update_attribute(:result_status, 'pending_approval')
      end

      it 'should return true if result is pending approval and user have permission' do
        expect(helper.show_approval_buttons?(microscopy_result, user)).to be true
      end
    end

    context 'with invalid data' do
      it 'should return false if result is pending approval and user does not have permission' do
        Policy.stub(:can?).and_return(false)
        microscopy_result.update_attribute(:result_status, 'pending_approval')

        expect(helper.show_approval_buttons?(microscopy_result, user)).to be false
      end

      it 'should return false if result is pending approval and user does not have permission' do
        Policy.stub(:can?).and_return(true)
        microscopy_result.update_attribute(:result_status, 'allocated')

        expect(helper.show_approval_buttons?(microscopy_result, user)).to be false
      end
    end
  end
end
