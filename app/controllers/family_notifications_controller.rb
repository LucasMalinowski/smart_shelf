class FamilyNotificationsController < ApplicationController
  before_action :authenticate_user!

  def update
    notification = current_user.family.family_notifications.find(params[:id])
    notification.mark_as_read!(current_user)
    flash.now[:notice] = "Notificação atualizada"
    load_notifications

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def mark_all
    notifications = current_user.family.family_notifications.unread
    notifications.update_all(status: FamilyNotification.statuses[:read], read_at: Time.current, read_by_id: current_user.id)
    flash.now[:notice] = "Notificações marcadas como lidas"
    load_notifications

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def load_notifications
    family = current_user.family
    @notifications = family.family_notifications.recent.limit(5)
    @unread_count = family.family_notifications.unread.count
  end
end
