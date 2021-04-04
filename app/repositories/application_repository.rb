# frozen_string_literal: true

class ApplicationRepository
  attr_accessor :organisation, :user

  def initialize(organisation, user)
    @organisation = organisation
    @user = user
  end
end
