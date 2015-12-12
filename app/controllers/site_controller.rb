class SiteController < ApplicationController
  before_filter :require_user, except: :home

  def home
  end

  def dashboard
  end

  def settings
  end


end
