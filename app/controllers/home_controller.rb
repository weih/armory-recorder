class HomeController < ApplicationController
  def index
    @char = Character.new
    @new_chars = Character.new_char
    @active_chars = Character.hot
    @leveling_chars = Character.leveling
  end

  def faq
    
  end

  def guestbook
    
  end

  def changelog
    
  end
end
