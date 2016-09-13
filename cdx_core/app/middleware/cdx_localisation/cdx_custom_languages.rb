module CdxLocalisation
  module CdxCustomLanguages
    extend ActiveSupport::Concern

    included do

    end

    class_methods do
      def active
        [[I18n.t("views.en"),"en"]]
      end
    end
  end
end
