class RequestedTest < ActiveRecord::Base
  belongs_to :encounter

  acts_as_paranoid

  has_one :xpert_result
  has_one :microscopy_result
  has_one :dst_lpa_result
  has_one :culture_result

  validates_presence_of :name
  enum status: [:pending, :inprogress, :completed, :rejected, :deleted]

  class << self
    def show_dst_warning
      dst_new     = false
      culture_new = false

      all.each do |requested_test|
        dst_new     = !requested_test.dst_lpa_result.present? if requested_test.name == 'dst'
        culture_new = !requested_test.culture_result.present? if requested_test.name == 'culture'
      end

      dst_new && culture_new
    end
  end
end
