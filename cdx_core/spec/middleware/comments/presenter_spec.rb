require 'spec_helper'

describe Comments::Presenter do
  let(:patient) { Patient.make }

  describe 'patient_view' do
    before :each do
      27.times { Comment.make patient: patient }
      @comments = patient.comments.page
    end

    it 'should return an array of formated comments' do
      expect(described_class.patient_view(@comments, '')['rows'].size).to eq(25)
    end

    it 'should return elements formated' do
      expect(described_class.patient_view(@comments, '')['rows'].first).to eq({
        id:          patient.comments.first.uuid,
        commentDate: Extras::Dates::Format.datetime_with_time_zone(patient.comments.first.created_at, :full_time),
        commenter:   patient.comments.first.user.full_name,
        title:       patient.comments.first.description,
        viewLink:    Rails.application.routes.url_helpers.patient_comment_path(patient, patient.comments.first)
      })
    end

    it 'includes pagination data' do
      expect(described_class.patient_view(@comments, '')['pages']).to eq(
        currentPage: 1,
        firstPage: true,
        lastPage: false,
        nextPage: 2,
        prevPage: nil,
        totalPages: 2
      )
    end
  end
end
