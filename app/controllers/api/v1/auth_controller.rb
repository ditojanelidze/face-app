module Api
  module V1
    class AuthController < BaseController
      # POST /api/v1/auth/request_otp
      def request_otp
        result = AuthenticationService.request_otp(otp_params[:phone_number])

        if result[:success]
          render json: { message: result[:message] }, status: :ok
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/register
      def register
        result = AuthenticationService.verify_registration(
          phone_number: register_params[:phone_number],
          code: register_params[:code],
          first_name: register_params[:first_name],
          last_name: register_params[:last_name]
        )

        if result[:success]
          render json: {
            message: "Registration successful",
            user: user_json(result[:user]),
            access_token: result[:access_token],
            refresh_token: result[:refresh_token]
          }, status: :created
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        result = AuthenticationService.verify_login(
          phone_number: login_params[:phone_number],
          code: login_params[:code],
          device_info: login_params[:device_info]
        )

        if result[:success]
          render json: {
            message: "Login successful",
            user: user_json(result[:user]),
            access_token: result[:access_token],
            refresh_token: result[:refresh_token]
          }, status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/refresh
      def refresh
        result = AuthenticationService.refresh_access_token(refresh_params[:refresh_token])

        if result[:success]
          render json: {
            access_token: result[:access_token],
            refresh_token: result[:refresh_token]
          }, status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        result = AuthenticationService.logout(refresh_params[:refresh_token])
        render json: { message: result[:message] }, status: :ok
      end

      # GET /api/v1/auth/check_phone
      def check_phone
        normalized_phone = OtpCode.normalize_phone(params[:phone_number])
        user_exists = User.exists?(phone_number: normalized_phone)

        render json: { exists: user_exists }, status: :ok
      end

      private

      def otp_params
        params.require(:auth).permit(:phone_number)
      end

      def register_params
        params.require(:auth).permit(:phone_number, :code, :first_name, :last_name)
      end

      def login_params
        params.require(:auth).permit(:phone_number, :code, :device_info)
      end

      def refresh_params
        params.require(:auth).permit(:refresh_token)
      end

      def user_json(user)
        {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          phone_number: user.phone_number,
          phone_verified: user.phone_verified,
          profile_complete: user.profile_complete?,
          created_at: user.created_at
        }
      end
    end
  end
end
