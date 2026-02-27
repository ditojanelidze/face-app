module Api
  module V1
    module Admin
      class AuthController < BaseController
        # POST /api/v1/admin/auth/login
        def login
          result = VenueAdminAuthenticationService.login(
            email: login_params[:email],
            password: login_params[:password]
          )

          if result[:success]
            render json: {
              message: "Login successful",
              admin: admin_json(result[:admin]),
              access_token: result[:access_token]
            }, status: :ok
          else
            render json: { error: result[:error] }, status: :unauthorized
          end
        end

        # POST /api/v1/admin/auth/register
        def register
          admin = VenueAdmin.new(register_params)

          if admin.save
            access_token = JwtService.encode_admin_access_token({
              admin_id: admin.id,
              role: "venue_admin"
            })

            render json: {
              message: "Registration successful",
              admin: admin_json(admin),
              access_token: access_token
            }, status: :created
          else
            render json: { error: admin.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        private

        def login_params
          params.require(:auth).permit(:email, :password)
        end

        def register_params
          params.require(:auth).permit(:email, :password, :password_confirmation, :first_name, :last_name)
        end

        def admin_json(admin)
          {
            id: admin.id,
            email: admin.email,
            first_name: admin.first_name,
            last_name: admin.last_name,
            created_at: admin.created_at
          }
        end
      end
    end
  end
end
