require 'spec_helper'

RSpec.describe Patients::Finder do
  let(:user)               { User.make }
  let(:institution)        { user.institutions.make }
  let(:institution2)       { user.institutions.make }
  let(:address)            { Address.make city: 'Sao Paulo'}
  let!(:patient)           { Patient.make institution: institution,  name: 'Ayrton Senna',  entity_id: 'McLaren',  birth_date_on: '1960-3-21', addresses: [address] }
  let!(:patient2)          { Patient.make institution: institution2, name: 'Ayrton Senna',  entity_id: 'McLaren',  birth_date_on: '1960-3-21', addresses: [Address.make] }
  let!(:patient3)          { Patient.make institution: institution,  name: 'Brunno Senna',  entity_id: 'Renault',  birth_date_on: '1983-10-15', addresses: [Address.make] }
  let!(:patient4)          { Patient.make institution: institution,  name: 'Jackie Ickx',   entity_id: 'Ferrari',  birth_date_on: '1945-1-1', addresses: [Address.make] }
  let!(:patient5)          { Patient.make institution: institution,  name: 'Nigel Mansel',  entity_id: 'Williams', birth_date_on: '1953-8-8', addresses: [Address.make] }
  let!(:patient6)          { Patient.make institution: institution,  name: 'Bruce McLaren', entity_id: 'Itself',   birth_date_on: '1937-8-30', addresses: [Address.make] }
  let(:navigation_context) { NavigationContext.new(user, institution.uuid) }
  let(:params) {
    { }
  }

  describe '#finder_query' do
    subject { described_class.new(user, navigation_context, params) }
    it 'should return an active record relation' do
      expect(subject.filter_query).to be_kind_of(ActiveRecord::Relation)
    end

    it 'should return all patients from that institution' do
      expect(subject.filter_query.count).to eq(5)
    end

    context 'search params' do
      context 'institution' do
        it 'should return all parents from active institution' do
          expect(subject.filter_query.count).to eq(5)
        end
      end

      context 'name' do
        let(:params) {
          { name: 'senna' }
        }

        it 'should return all patients with related name' do
          expect(subject.filter_query.count).to eq(2)
        end
      end

      context 'entity_id' do
        let(:params) {
          { entity_id: 'williams' }
        }

        it 'should return all patients with related name' do
          expect(subject.filter_query.count).to eq(1)
        end
      end

      context 'birth date since' do
        let(:params) {
          { since_dob: '1945-1-2' }
        }

        it 'should return all patients with related name' do
          expect(subject.filter_query.count).to eq(3)
        end
      end

      context 'birth date until' do
        let(:params) {
          { since_dob: '1900-1-1', until_dob: '1980-12-31' }
        }

        it 'should return all patients with related name' do
          expect(subject.filter_query.count).to eq(4)
        end
      end

      context 'address' do
        let(:params) {
          { address: 'paulo' }
        }

        it 'should return all patients with related name' do
          expect(subject.filter_query.count).to eq(1)
        end
      end
    end
  end
end
