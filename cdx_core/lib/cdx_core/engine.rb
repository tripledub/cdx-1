module CdxCore
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    config.autoload_paths += %W(#{CdxCore::Engine.root}/lib)
    config.i18n.load_path += Dir[File.join(CdxCore::Engine.root, 'config', 'locales', '**', '*.{rb,yml}')]
    config.assets.precompile += %w(barcode-print.css)
    config.assets.precompile += %w(page-print.css)

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
