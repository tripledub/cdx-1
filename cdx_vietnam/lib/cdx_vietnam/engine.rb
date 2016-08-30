module CdxVietnam
  class Engine < ::Rails::Engine
    config.i18n.load_path += Dir[File.join(CdxVietnam::Engine.root, 'config', 'locales', '**', '*.{rb,yml}')]
  end
end
