# New finance approved feedback message
class AddNewFinanceApprovalContent < ActiveRecord::Migration
  def up
    Institution.all.each do |institution|
      nf004 = institution.feedback_messages.create!(category: 'finance', code: 'NF0004')
      nf004.custom_translations.create!(lang: 'en', text: 'Patient not processed')
    end
  end

  def down
    Institution.all.each do |institution|
      nf004 = institution.feedback_messages.where(code: 'NF0004').first
      nf004.destroy
    end
  end
end
