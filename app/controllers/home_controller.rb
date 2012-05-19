class HomeController < ApplicationController
  caches_page :faq, :guestbook
  
  def index
    @char = Character.new
    @new_chars = Character.new_char
    @active_chars = Character.hot
    @leveling_chars = Character.leveling
  end

  def faq
    
  end

  def guestbook
    expires_in 1.hour, :private => false, :public => true
  end

  def changelog
    expires_in 1.hour, :private => false, :public => true
  end
end
