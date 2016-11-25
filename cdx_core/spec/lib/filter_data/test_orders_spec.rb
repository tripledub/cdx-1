require 'spec_helper'

describe FilterData::TestOrders do
  let(:default_values) do
    {
      'page_size' => '50',
      'testing_for' => 'TB',
      'status' => 'allocated',
      'since' => '2016-09-27'
    }
  end
  let(:cookie_values) { default_values.to_json }
  let(:cookies) { { 'testorders' => cookie_values } }

  describe 'params' do
    subject { described_class.new(params, cookies) }

    before :each do
      subject.update
    end

    context 'when params are empty' do
      let(:params) { {} }

      context 'if there are values stored' do
        it 'should return stored values' do
          expect(subject.params).to eq(default_values)
        end

        it 'should update filter values' do
          expect(subject.current_data).to eq(default_values)
        end
      end
    end

    context 'if params are present' do
      let(:params) { default_values.merge('status' => 'samples_collected', 'page_size' => '100') }

      it 'should return params values if present' do
        expect(params).to eq(subject.params)
      end

      it 'should update filter values' do
        expect(subject.current_data).to eq(params)
      end
    end
  end
end
