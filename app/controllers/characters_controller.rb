# coding: utf-8

class CharactersController < ApplicationController
  caches_page :show, :expires_in => 1.hours

  def show
    @char = Character.find(params[:id])
    
    @chars_same_server = Character.same_server(@char).all.sample(6) - [@char]
  end

  def create
    @char = Character.find_by_server_and_name(params[:character][:server], params[:character][:name])
    
    if @char
      redirect_to character_path @char
    else
      @new_char = Character.new(params[:character])
      @new_char.fetch_armory(true)

#      expire_page root_path
      expire_fragment "form"
      expire_fragment "new_chars"
      expire_fragment "leveling_random"
      expire_fragment "footer"

      logger.debug @new_char.char_status
      case @new_char.char_status
      when 200
        redirect_to @new_char, notice: "角色登记成功"
      when 404
        redirect_to root_path, alert: "很抱歉，未找到角色您的角色，请检查您的角色名与服务器是否正确"
      when 503
        redirect_to root_path, alert: "很抱歉，由于该角色长期未活动，已被冻结，无法记录"
      end
    end
  end
end
