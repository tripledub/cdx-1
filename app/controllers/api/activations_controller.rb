class Api::ActivationsController < ApiController
  skip_before_action :doorkeeper_authorize!

  def create
    device = Device.find_by(activation_token: params[:token].delete("-"))
    response = if device.nil?
        { status: :failure, message: I18n.t('api.activations_controller.invalid_token') }
      elsif params[:public_key]
        begin
          settings = device.use_activation_token_for_ssh_key!(params[:public_key])
          { status: :success, message: I18n.t('api.activations_controller.device_activated'), settings: settings }
        rescue CDXSync::InvalidPublicKeyError => e
          { status: :failure, message: I18n.t('api.activations_controller.invalid_key') }
        end
      elsif params[:generate_key]
        secret_key = device.use_activation_token_for_secret_key!
        { status: :success, message: I18n.t('api.activations_controller.device_activated'), settings: { device_key: secret_key, device_uuid: device.uuid } }
      else
        { status: :failure, message: I18n.t('api.activations_controller.missing_key') }
      end

    logger.info "Response for activation request #{params[:token]}: #{response}"
    render json: response
  end
end
