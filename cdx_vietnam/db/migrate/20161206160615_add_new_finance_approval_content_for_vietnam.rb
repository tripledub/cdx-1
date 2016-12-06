# Add new translation for Not Financed feedback messages
class AddNewFinanceApprovalContentForVietnam < ActiveRecord::Migration
  def up
    Institution.all.each do |institution|
      nf004 = institution.feedback_messages.where(code: 'NF0004').first
      nf004.custom_translations.create!(lang: 'vi', text: 'Patient not processed')
    end
  end

  def down
    Institution.all.each do |institution|
      nf004  = institution.feedback_messages.where(code: 'NF0004').first
      custom = nf004.custom_translations.where(lang: 'vi').first
      custom.destroy
    end
  end
end
