class Episode < ActiveRecord::Base
  def self.history_options
    [
      OpenStruct.new(id: :new, name: I18n.t('select.episode.history.new'), initial: true),
      OpenStruct.new(id: :previous, name: I18n.t('select.episode.history.previous'), initial: true),
      OpenStruct.new(id: :unknown, name: I18n.t('select.episode.history.unknown'), initial: true),
      OpenStruct.new(id: :relapsed, name: I18n.t('select.episode.history.relapsed')),
      OpenStruct.new(id: :loss, name: I18n.t('select.episode.history.loss')),
      OpenStruct.new(id: :failcati, name: I18n.t('select.episode.history.failcati')),
      OpenStruct.new(id: :failcatii, name: I18n.t('select.episode.history.failcatii')),
      OpenStruct.new(id: :noncon, name: I18n.t('select.episode.history.noncon')),
      OpenStruct.new(id: :relepsecat, name: I18n.t('select.episode.history.relepsecat')),
      OpenStruct.new(id: :retreatcat, name: I18n.t('select.episode.history.retreatcat')),
      OpenStruct.new(id: :tbmdr, name: I18n.t('select.episode.history.tbmdr')),
      OpenStruct.new(id: :other, name: I18n.t('select.episode.history.other'))
    ]
  end
end
