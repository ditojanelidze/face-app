class RefreshToken
  include Interactor

  def call
    session = Session.find_by(refresh_token: context.refresh_token)
    context.fail!(error: "Invalid refresh token") unless session
    context.fail!(error: "Session expired") if session.expired?

    access_token = JwtService.encode_access_token({ user_id: session.user_id })

    context.access_token = access_token
    context.refresh_token = session.refresh_token
  end
end
