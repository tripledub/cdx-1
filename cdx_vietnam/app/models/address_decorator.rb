# CdxVietnam decorator for Address
class Address < ActiveRecord::Base
  def self.regions
    [
      ['northern', I18n.t('select.address.regions.northern')],
      ['southern', I18n.t('select.address.regions.southern')],
      ['central', I18n.t('select.address.regions.central')]
    ]
  end

  validates :state, inclusion: { in: Address.regions.map(&:first) }, allow_blank: true
end
