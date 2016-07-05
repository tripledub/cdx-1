require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe ':form_title' do
    context 'when creating a new object' do
      let(:user) { User.make_unsaved }
      it 'the title begins with New' do
        expect(helper.form_title(user)).to eq('New User')
      end
    end

    context 'when updating an existing object' do
      let(:user) { User.make }
      it 'the title begins with Edit' do
        expect(helper.form_title(user)).to eq('Edit User')
      end
    end

    context 'with custom text' do
      let(:user) { User.make }
      it 'the title includes custom text' do
        expect(helper.form_title(user, 'Foo')).to eq('Edit Foo')
      end
    end
  end
end
