module CdxVietnam
  class Engine < ::Rails::Engine
    config.autoload_paths += %W(#{CdxVietnam::Engine.root}/lib)
    config.i18n.load_path += Dir[File.join(CdxVietnam::Engine.root, 'config', 'locales', '**', '*.{rb,yml}')]

    initializer :set_decorator_paths, before: :load_environment_hook do |app|
      ActiveSupportDecorators.paths << File.join(config.root, 'app/**')
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
