class ThemesController < ApplicationController
  protect_from_forgery with: :exception

  def update
    theme = permitted_theme
    session[:theme] = theme
    head :ok
  end

  private

  def permitted_theme
    value = params[:theme].to_s.downcase
    return "dark" if value == "dark"

    "light"
  end
end
