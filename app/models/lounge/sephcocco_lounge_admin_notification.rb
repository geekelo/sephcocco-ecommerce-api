class SephcoccoLoungeAdminNotification < ApplicationRecord
  belongs_to :sephcocco_user

  after_update :switch_visibility

  private

  def switch_visibility
    if viewed
      # Logic to switch visibility
      self.update(visible: false)
    else
      self.update(visible: true)
    end
  end
end