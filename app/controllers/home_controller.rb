class HomeController < ApplicationController
  caches_page :faq, :guestbook
  
  def index
    @char = Character.new
    @new_chars = Character.new_char
    @random_chars = Character.random_char.all.sample(8)
    @leveling_chars = Character.leveling.all.sample(8)
  end

  def faq
    expires_in 1.hour, :private => false, :public => true    
  end

  def guestbook
    expires_in 1.hour, :private => false, :public => true
  end
end
