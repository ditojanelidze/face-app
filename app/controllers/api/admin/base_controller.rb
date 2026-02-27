module Api
  module Admin
    class BaseController < Api::BaseController
      include AdminAuthenticatable
    end
  end
end
