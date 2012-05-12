class HomeController < ApplicationController
  layout nil

  def index
    @char = Character.new
    @new_chars = Character.order("created_at DESC")
    @active_chars = Character.order("histories_count DESC")
    @leveling_chars = Character.where(leveling: true).order("histories_count DESC, level DESC")
  end
end
