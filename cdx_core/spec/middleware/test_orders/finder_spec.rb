require 'spec_helper'

RSpec.describe TestOrders::Finder do
  let(:user)               { User.make }
  let!(:institution)       { user.institutions.make }
  let(:site)               { Site.make institution: institution }
  let(:site2)              { Site.make institution: institution }
  let(:site3)              { Site.make institution: institution, parent_id: site2.id }
  let(:patient)            { Patient.make institution: institution }
  let!(:test_order)        { Encounter.make institution: institution, site: site,  patient: patient, start_time: 3.days.ago.strftime("%Y-%m-%d"),  testdue_date: 1.day.from_now.strftime("%Y-%m-%d"),  testing_for: 'TB' }
  let!(:test_order2)       { Encounter.make institution: institution, site: site,  patient: patient, start_time: 30.days.ago.strftime("%Y-%m-%d"), testdue_date: 2.days.from_now.strftime("%Y-%m-%d"), testing_for: 'HIV' }
  let!(:test_order3)       { Encounter.make institution: institution, site: site2, patient: patient, start_time: 7.days.ago.strftime("%Y-%m-%d"),  testdue_date: 3.days.from_now.strftime("%Y-%m-%d") }
  let!(:test_order4)       { Encounter.make institution: institution, site: site,  patient: patient, start_time: 14.days.ago.strftime("%Y-%m-%d"), testdue_date: 4.days.from_now.strftime("%Y-%m-%d"), testing_for: 'TB' }
  let!(:test_order5)       { Encounter.make institution: institution, site: site2, patient: patient, start_time: 23.days.ago.strftime("%Y-%m-%d"), testdue_date: 5.days.from_now.strftime("%Y-%m-%d") }
  let!(:test_order6)       { Encounter.make institution: institution, site: site3, patient: patient, start_time: 93.days.ago.strftime("%Y-%m-%d"), testdue_date: 6.days.from_now.strftime("%Y-%m-%d"), testing_for: 'EBOLA' }
  let!(:test_order7)       { Encounter.make institution: institution, site: site3, patient: patient, start_time: 93.days.ago.strftime("%Y-%m-%d"), testdue_date: 2.days.from_now.strftime("%Y-%m-%d"), testing_for: 'EBOLA' }
  let!(:test_order8)       { Encounter.make institution: institution, site: site3, patient: patient, start_time: 93.days.ago.strftime("%Y-%m-%d"), testdue_date: 3.days.from_now.strftime("%Y-%m-%d"), testing_for: 'EBOLA' }
  let(:navigation_context) { NavigationContext.new(user, institution.uuid) }
  let(:params) { {} }

  before :each do
    encounter = Encounter.make institution: institution, site: site3, patient: patient, start_time: 93.days.ago.strftime("%Y-%m-%d"), testdue_date: 6.days.from_now.strftime("%Y-%m-%d"), testing_for: 'EBOLA'
    encounter.update_attribute(:status, 'not_financed')
    test_order7.update_attribute(:status, 'not_financed')
    test_order8.update_attribute(:status, 'closed')
  end

  before :each do
    encounter = Encounter.make institution: institution, site: site3, patient: patient, start_time: 93.days.ago.strftime("%Y-%m-%d"), testdue_date: 6.days.from_now.strftime("%Y-%m-%d"), testing_for: 'EBOLA'
    encounter.update_attribute(:status, 'not_financed')
  end


  describe '#finder_query' do
    context 'when navigation context is the institution' do
      subject { described_class.new(navigation_context, params) }

      it 'should return an active record relation' do
        expect(subject.filter_query).to be_kind_of(ActiveRecord::Relation)
      end

      it 'should return outstanding test orders from that institution' do
        expect(subject.filter_query.count).to eq(6)
      end
    end

    context 'filter params' do
      context 'Single encounter Id' do
        subject { described_class.new(navigation_context, { 'encounter_id' => test_order2.uuid }) }

        it 'should return a single encounter when filter by id' do
          expect(subject.filter_query.count).to eq(1)
        end

        it 'should return the requested encounter when filter by id' do
          expect(subject.filter_query.first).to eq(test_order2)
        end
      end

      context 'Array of encounter ids' do
        subject { described_class.new(navigation_context, { 'selectedItems' => [test_order2.id, test_order3.id, test_order5.id] }) }

        it 'should return a single encounter when filter by id' do
          expect(subject.filter_query.count).to eq(3)
        end

        it 'should return the requested encounter when filter by id' do
          expect(subject.filter_query).to include(test_order5)
          expect(subject.filter_query).to include(test_order2)
        end
      end

      context 'Testing for' do
        subject { described_class.new(navigation_context, { 'testing_for' => 'TB' }) }

        it 'should return a single encounter when filter by id' do
          expect(subject.filter_query.count).to eq(2)
        end

        it 'should return the requested encounter when filter by id' do
          expect(subject.filter_query).to include(test_order)
          expect(subject.filter_query).to include(test_order4)
        end
      end

      context 'Status' do
        context 'single status' do
          subject { described_class.new(navigation_context, 'status' => 'new') }

          it 'should return a single encounter when filter by id' do
            expect(subject.filter_query.count).to eq(6)
          end

          it 'should return the requested encounter when filter by id' do
            expect(subject.filter_query).to include(test_order2)
            expect(subject.filter_query).to include(test_order5)
            expect(subject.filter_query).to include(test_order6)
          end
        end

        context 'ongoing test orders' do
          subject { described_class.new(navigation_context, {}) }

          it 'should show all ongoing test orders' do
            expect(subject.filter_query).to include(test_order2)
          end

          it 'should not include closed test orders' do
            expect(subject.filter_query).to_not include(test_order7)
          end

          it 'should not include not financed test orders' do
            expect(subject.filter_query).to_not include(test_order8)
          end
        end
      end

      context 'Since' do
        subject { described_class.new(navigation_context, { 'since' => 25.days.ago.strftime("%Y-%m-%d") }) }

        it 'should return the right number of encounters' do
          expect(subject.filter_query.count).to eq(4)
        end

        it 'should return the encounter data' do
          expect(subject.filter_query).to include(test_order)
          expect(subject.filter_query).to include(test_order4)
          expect(subject.filter_query).to include(test_order5)
        end
      end
    end

    describe 'search by batch id' do
      context 'search by full id' do
        subject { described_class.new(navigation_context, params.merge!('batch_id' => test_order.batch_id)) }

        it 'should return all test orders from that site and subsites' do
          expect(subject.filter_query.count).to eq(1)
        end
      end

      context 'search by id' do
        subject { described_class.new(navigation_context, params.merge!('batch_id' => test_order2.id.to_s)) }

        it 'should return all test orders from that site and subsites' do
          expect(subject.filter_query.count).to eq(1)
        end
      end
    end

    context 'when navigation context is a site with subsites' do
      let(:navigation_context) { NavigationContext.new(user, site2.uuid) }

      subject { described_class.new(navigation_context, params) }

      it 'should return all test orders from that site and subsites' do
        expect(subject.filter_query.count).to eq(3)
      end
    end

    context 'when navigation context is a site with no subsites' do
      let(:navigation_context) { NavigationContext.new(user, "#{site2.uuid}-!") }

      subject { described_class.new(navigation_context, params) }

      it 'should return all test orders from that site' do
        expect(subject.filter_query.count).to eq(2)
      end
    end
  end
end
