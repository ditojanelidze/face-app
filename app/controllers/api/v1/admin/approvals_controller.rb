module Api
  module V1
    module Admin
      class ApprovalsController < BaseController
        before_action :set_venue
        before_action :set_approval, only: [:show, :approve, :reject]

        # GET /api/v1/admin/venues/:venue_id/approvals
        def index
          approvals = @venue.approvals.includes(:user, :event)

          # Filter by status if provided
          if params[:status].present?
            approvals = approvals.where(status: params[:status])
          end

          # Filter by type if provided
          if params[:type].present?
            approvals = approvals.where(approval_type: params[:type])
          end

          render json: {
            approvals: approvals.map { |a| approval_json(a) }
          }, status: :ok
        end

        # GET /api/v1/admin/venues/:venue_id/approvals/pending
        def pending
          approvals = @venue.approvals.pending.includes(:user, :event)

          render json: {
            approvals: approvals.map { |a| approval_json(a) }
          }, status: :ok
        end

        # GET /api/v1/admin/venues/:venue_id/approvals/:id
        def show
          render json: {
            approval: approval_json(@approval, include_user_details: true)
          }, status: :ok
        end

        # POST /api/v1/admin/venues/:venue_id/approvals/:id/approve
        def approve
          unless @approval.pending?
            return render json: { error: "Approval is not in pending state" }, status: :unprocessable_entity
          end

          expires_at = params[:expires_at].present? ? Time.parse(params[:expires_at]) : nil

          if @approval.update(status: :approved, expires_at: expires_at)
            render json: {
              message: "User approved successfully",
              approval: approval_json(@approval)
            }, status: :ok
          else
            render json: { error: @approval.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/admin/venues/:venue_id/approvals/:id/reject
        def reject
          unless @approval.pending?
            return render json: { error: "Approval is not in pending state" }, status: :unprocessable_entity
          end

          if @approval.update(status: :rejected)
            render json: {
              message: "User rejected",
              approval: approval_json(@approval)
            }, status: :ok
          else
            render json: { error: @approval.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        private

        def set_venue
          @venue = current_admin.venues.find(params[:venue_id])
        end

        def set_approval
          @approval = @venue.approvals.find(params[:id])
        end

        def approval_json(approval, include_user_details: false)
          json = {
            id: approval.id,
            user: user_summary(approval.user),
            event: approval.event ? {
              id: approval.event.id,
              name: approval.event.name,
              date_time: approval.event.date_time
            } : nil,
            approval_type: approval.approval_type,
            status: approval.status,
            active: approval.active?,
            qr_used: approval.qr_used,
            expires_at: approval.expires_at,
            created_at: approval.created_at,
            updated_at: approval.updated_at
          }

          if include_user_details
            json[:user_details] = user_details(approval.user)
          end

          json
        end

        def user_summary(user)
          {
            id: user.id,
            full_name: user.full_name,
            phone_number: user.phone_number
          }
        end

        def user_details(user)
          details = {
            id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            full_name: user.full_name,
            phone_number: user.phone_number,
            phone_verified: user.phone_verified,
            social_links: user.social_links,
            created_at: user.created_at
          }

          details[:profile_photo_url] = url_for(user.profile_photo) if user.profile_photo.attached?
          details[:id_card_image_url] = url_for(user.id_card_image) if user.id_card_image.attached?

          details
        end
      end
    end
  end
end
