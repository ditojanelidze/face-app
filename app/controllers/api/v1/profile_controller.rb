module Api
  module V1
    class ProfileController < BaseController
      include UserAuthenticatable

      # GET /api/v1/profile
      def show
        render json: { user: user_json(current_user) }, status: :ok
      end

      # PATCH /api/v1/profile
      def update
        if current_user.update(profile_params)
          render json: { user: user_json(current_user) }, status: :ok
        else
          render json: { error: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/profile/upload_photo
      def upload_photo
        unless params[:photo].present?
          return render json: { error: "Photo is required" }, status: :bad_request
        end

        current_user.profile_photo.attach(params[:photo])

        if current_user.profile_photo.attached?
          render json: {
            message: "Photo uploaded successfully",
            photo_url: url_for(current_user.profile_photo)
          }, status: :ok
        else
          render json: { error: "Failed to upload photo" }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/profile/upload_id_card
      def upload_id_card
        unless params[:id_card].present?
          return render json: { error: "ID card image is required" }, status: :bad_request
        end

        current_user.id_card_image.attach(params[:id_card])

        if current_user.id_card_image.attached?
          render json: {
            message: "ID card uploaded successfully",
            id_card_url: url_for(current_user.id_card_image)
          }, status: :ok
        else
          render json: { error: "Failed to upload ID card" }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/profile/approvals
      def approvals
        approvals = current_user.approvals.includes(:venue, :event)

        render json: {
          approvals: approvals.map { |a| approval_json(a) }
        }, status: :ok
      end

      # GET /api/v1/profile/active_approvals
      def active_approvals
        approvals = current_user.approvals.active.includes(:venue, :event)

        render json: {
          approvals: approvals.map { |a| approval_json(a) }
        }, status: :ok
      end

      private

      def profile_params
        params.require(:profile).permit(:first_name, :last_name, :facebook_url, :instagram_url, :linkedin_url)
      end

      def user_json(user)
        json = {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          phone_number: user.phone_number,
          phone_verified: user.phone_verified,
          profile_complete: user.profile_complete?,
          social_links: user.social_links,
          created_at: user.created_at,
          updated_at: user.updated_at
        }

        json[:profile_photo_url] = url_for(user.profile_photo) if user.profile_photo.attached?
        json[:id_card_image_url] = url_for(user.id_card_image) if user.id_card_image.attached?

        json
      end

      def approval_json(approval)
        {
          id: approval.id,
          venue: {
            id: approval.venue.id,
            name: approval.venue.name
          },
          event: approval.event ? {
            id: approval.event.id,
            name: approval.event.name,
            date_time: approval.event.date_time
          } : nil,
          approval_type: approval.approval_type,
          status: approval.status,
          active: approval.active?,
          expires_at: approval.expires_at,
          created_at: approval.created_at
        }
      end
    end
  end
end
