class CharactersController < ApplicationController
  caches_page :show, :expires_in => 1.hours

  def show
    @char = Character.find(params[:id])
    
    @chars_same_server = Rails.cache.fetch("chars_same_server", :expire_in => 3.hours) { Character.same_server(@char).all }.sample(6) - [@char]
  end

  def create
    @char = Character.find_by_server_and_name(params[:character][:server], params[:character][:name])
    
    if @char
      redirect_to character_path @char
    else
      @new_char = Character.new(params[:character])
      res, msg = @new_char.fetch_armory(true)

#      expire_page root_path
      expire_fragment "form"
      expire_fragment "new_chars"
      expire_fragment "footer"

      case res
      when 200
        redirect_to @new_char, notice: msg
      when 404
        redirect_to root_path, alert: msg
      when 503
        redirect_to root_path, alert: msg
      end
    end
  end
end
