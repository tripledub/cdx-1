require 'spec_helper'

describe XpertResult do
  let(:institution)         { Institution.make }
  let(:user)                { institution.user }
  let(:site)                { institution.sites.make }
  let(:patient)             { Patient.make(institution: institution) }
  let(:encounter)           { Encounter.make institution: institution, site: site, patient: patient }
  let(:xpert_result)        { XpertResult.make encounter: encounter }
  let(:result_status)       { %w(new sample_collected allocated pending_approval rejected completed) }
  let(:test_result_options) { %w(detected not_detected indeterminate) }

  before :each do
    User.current = user
  end

  context 'validations' do
    it { should validate_presence_of(:sample_collected_at).on(:update) }
    it { should validate_presence_of(:tuberculosis).on(:update) }
    it { should validate_presence_of(:examined_by).on(:update) }
    it { should validate_presence_of(:result_at).on(:update) }
    it { should validate_inclusion_of(:result_status).in_array(result_status) }
    it { should validate_inclusion_of(:tuberculosis).in_array(test_result_options).allow_nil }

    context 'rifampicin' do
      context 'tuberculosis has been detected' do
        context 'rifampicin is not present' do
          subject { XpertResult.new encounter: encounter, result_at: 3.days.from_now, examined_by: 'The doctor', sample_collected_at: 1.day.ago, tuberculosis: 'detected', rifampicin: nil }

          it 'should be invalid' do
            expect(subject.valid?).to be false
          end
        end

        context 'if is detected and tuberculosis is not detected' do
          subject { XpertResult.new encounter: encounter, result_at: 3.days.from_now, examined_by: 'The doctor', sample_collected_at: 1.day.ago, tuberculosis: 'not_detected', rifampicin: 'detected' }

          it 'should not be valid' do
            expect(subject.valid?).to be false

            expect(subject.errors.messages[:rifampicin].first).to eq("It's not possible to select Rifampicin as detected unless M. tuberculosis has been detected.")
          end
        end

        context 'tuberculosis has not been detected' do
          context 'rifampicin is not present' do
            subject { XpertResult.new encounter: encounter, result_at: 3.days.from_now, examined_by: 'The doctor', sample_collected_at: 1.day.ago, tuberculosis: 'indeterminate', rifampicin: nil }

            it 'should be valid' do
              expect(subject.valid?).to be true
            end
          end
        end
      end


      context 'if is detected and tuberculosis is detected' do
        subject { XpertResult.new encounter: encounter, result_at: 3.days.from_now, examined_by: 'The doctor', sample_collected_at: 1.day.ago, tuberculosis: 'detected', rifampicin: 'detected' }

        it 'should be valid' do
          expect(subject.valid?).to be
        end
      end
    end

    context 'linkable?' do
      it 'should return true if status is allocated' do
        xpert_result.update_attribute(:result_status, 'allocated')
        expect(xpert_result.linkable?).to be true
      end

      it 'should return false if status is not allocated' do
        expect(xpert_result.linkable?).to be false
      end
    end
  end
end
