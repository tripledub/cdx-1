module CdxCore
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    config.i18n.load_path += Dir[File.join(CdxCore::Engine.root, 'config', 'locales', '**', '*.{rb,yml}')]
  end
end
