module Api

  class AuthController < BaseController
    # POST /api/auth/register
    # Step 1: create pending user + send OTP
    def register
      result = RegisterUser.call(register_params)
      if result.success?
        render json: { message: "OTP sent to your phone number" }, status: :created
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    end

    # POST /api/auth/confirm_registration
    # Step 2: verify OTP, activate user, return tokens
    def confirm_registration
      result = ConfirmRegistration.call(
        phone_number: params[:phone_number],
        sms_code: params[:sms_code]
      )
      if result.success?
        render json: {
          message: "Registration confirmed",
          user: user_json(result.user),
          access_token: result.access_token,
          refresh_token: result.refresh_token
        }, status: :ok
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    end

    # POST /api/auth/login
    # Login step 1: send OTP to existing user's phone
    def login
      result = SendLoginOtp.call(phone_number: params[:phone_number])
      if result.success?
        render json: { message: "OTP sent successfully" }, status: :ok
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    end

    # POST /api/auth/confirm_login
    # Login step 2: verify OTP and return tokens
    def confirm_login
      result = ConfirmLogin.call(
        phone_number: params[:phone_number],
        sms_code: params[:sms_code],
        device_info: params[:device_info]
      )
      if result.success?
        render json: {
          message: "Login successful",
          user: user_json(result.user),
          access_token: result.access_token,
          refresh_token: result.refresh_token
        }, status: :ok
      else
        render json: { error: result.error }, status: :unauthorized
      end
    end

    # POST /api/auth/refresh
    def refresh
      result = RefreshToken.call(refresh_token: params[:refresh_token])
      if result.success?
        render json: {
          access_token: result.access_token,
          refresh_token: result.refresh_token
        }, status: :ok
      else
        render json: { error: result.error }, status: :unauthorized
      end
    end

    # DELETE /api/auth/logout
    def logout
      result = Logout.call(refresh_token: params[:refresh_token])
      render json: { message: result.message }, status: :ok
    end

    private

    def register_params
      params.permit(:phone_number, :first_name, :last_name)
    end

    def user_json(user)
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        phone_number: user.phone_number,
        phone_verified: user.phone_verified,
        role: user.role,
        created_at: user.created_at
      }
    end
  end

end
