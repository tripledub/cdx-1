module CdxLocalisation
  class Languages
    include CdxCustomLanguages

    class << self
      def active
        [[I18n.t("views.en"),"en"], [I18n.t("views.vi"), "vi"]]
      end
    end
  end
end
