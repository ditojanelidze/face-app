class Logout
  include Interactor

  def call
    session = Session.find_by(refresh_token: context.refresh_token)
    session&.destroy
    context.message = "Logged out successfully"
  end
end
