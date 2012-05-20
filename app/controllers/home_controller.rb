class HomeController < ApplicationController
  caches_page :faq, :guestbook, :expires_in => 1.hours
  caches_page :index, :expires_in => 5.minutes
  
  def index
    @char = Character.new
    @new_chars = Character.new_char
    @random_chars = Character.random_char.all.sample(8)
    @leveling_chars = Character.leveling.all.sample(8)
  end

  def faq
  end

  def guestbook
  end
end
