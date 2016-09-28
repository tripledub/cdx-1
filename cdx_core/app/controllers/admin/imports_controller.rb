module Admin
  class ImportsController < Admin::BaseController

    skip_before_action :ensure_context
    skip_before_action :check_no_institution!

    def index
      if request.post?
        @import = Import::Base.import(import_params)

        if @import.process
          redirect_to([:admin, :imports], :notice => I18n.t('admin/imports_controller.index.success'))
        else
          flast.now[:alert] = I18n.t('admin/imports_controller.index.failure')
        end

      end
    end

    private

      def import_params
        params.require(:import).permit(:file, :import_type, :clear_current_data)
      end
  end
end
