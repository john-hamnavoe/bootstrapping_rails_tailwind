class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_in_organisation!

  def index
    # Convert the database records to Noticed notification instances so we can use helper methods
    # @notifications = current_user.notifications.map(&:to_notification)
  end

  def mark_as_read
    Notification.find_by(id: params[:notification_id]).update(read_at: Time.zone.now)
    redirect_to notifications_path
  end

  def mark_all_as_read
    Notification.where(recipient_type: "User", recipient: current_user, read_at: nil).update(read_at: Time.zone.now)
    redirect_to notifications_path
  end
end
