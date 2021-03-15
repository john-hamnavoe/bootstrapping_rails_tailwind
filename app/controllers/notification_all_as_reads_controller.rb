class NotificationAllAsReadsController < ApplicationController
  before_action :authenticate_user!

  def update
    Notification.where(recipient_type: "User", recipient: current_user, read_at: nil).update(read_at: Time.zone.now)
    redirect_to notifications_path
  end
end
