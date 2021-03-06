class RawPhotosController < ApplicationController
  before_action :require_login

  def show
    send_file PhotoService.raw_path(current_user.screen_name), type: 'image/png', disposition: 'inline'
  end

  def update
    unless params[:rawPhoto]
      redirect_back fallback_location: edit_profile_path(current_user.screen_name),
        alert: 'Nincs kép kiválasztva'
      return
    end

    PhotoService.upload_raw(current_user.screen_name, params[:rawPhoto])

    redirect_to edit_photo_path(current_user.screen_name)
  end
end
