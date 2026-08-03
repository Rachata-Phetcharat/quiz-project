class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_user

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def set_current_user
    @current_user = Customer.find_by(name: "Customer A") || Customer.create!(
      u_id: "customer_a_#{Time.now.to_i}",
      name: "Customer A",
      balance: 1500.00
    )
  end
end
