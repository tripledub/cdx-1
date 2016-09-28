module CdxApiCore
  module V1
    # POST /activations
    class Activation < Grape::API

      desc 'Activate a device'
      post :activations do

        device = Device.find_by(activation_token: params[:token].delete("-"))

        unless device
          error!({ status: :failure, message: 'Invalid activation token' }, 403)
        end

        if params[:public_key]
          begin
            settings = device.use_activation_token_for_ssh_key!(params[:public_key])
            { status: :success, message: 'Device activated', settings: settings }
          rescue CDXSync::InvalidPublicKeyError => e
            error!({ status: :failure, message: 'Invalid public key' }, 422)
          end
        elsif params[:generate_key]
          secret_key = device.use_activation_token_for_secret_key!
          { status: :success, message: 'Device activated', settings: { device_key: secret_key, device_uuid: device.uuid } }
        else
          error!({ status: :failure, message: 'Missing public_key or generate_key parameter' }, 403)
        end

      end
    end
  end
end