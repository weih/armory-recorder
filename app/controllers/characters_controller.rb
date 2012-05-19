class CharactersController < ApplicationController
  caches_page :show

  def show
    expires_in 1.hour, :private => false, :public => true
    @char = Character.find(params[:id])
  end

  def create
    @char = Character.find_by_server_and_name(params[:character][:server], params[:character][:name])
    
    if @char
      redirect_to character_path @char
    else
      @new_char = Character.new(params[:character])
      res, msg = @new_char.fetch_armory(true)

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
