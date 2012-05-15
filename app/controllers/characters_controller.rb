class CharactersController < ApplicationController
  def index
  end

  def show
    logger.debug flash[:notice]
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
      when '200'
        logger.debug msg
        logger.debug @new_char.name
        logger.debug @new_char.server
        logger.debug @new_char.valid?
        redirect_to @new_char, notice: msg
      when '404'
        redirect_to root_path, alert: msg
      when '503'
        redirect_to root_path, alert: msg
      end
      # create char and fetch today's armory
    end
  end
end
