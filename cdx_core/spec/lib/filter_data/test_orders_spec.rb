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
  let(:cookies) { { 'test_orders' => cookie_values } }

  describe 'params' do
    context 'when params are empty' do
      let(:params) { {} }


      context 'if there are values stored' do
        it 'should return stored values' do
          filter_data = described_class.new(params, cookies)
          filter_data.update
          params = filter_data.params

          expect(params).to eq(default_values)
        end
      end

    end

    context 'if params are present' do
      it 'should return params values if present' do

      end

      it 'should update stored information' do

      end
    end
  end
end
