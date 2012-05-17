# coding: utf-8

require 'spec_helper'

describe CharactersController do
  describe ":show" do
    it "returns http success" do
      char = FactoryGirl.create(:character)
      get :show, :id => char.id
      response.should be_success
    end
  end
  
  describe ":create" do
    it "should redirect_to character#show when create character success" do
      post :create, :character => { :server => "戈提克", :name => "Bigdaddy" }
      @new_char = Character.last
      flash[:notice].should == "角色登记成功"
      response.should redirect_to(@new_char)
    end

    it "should redirect_to root_path with 404 when character is not found" do
      post :create, :character => { :server => "Unkonw Server", :name => "Unkonw Name" }
      flash[:alert].should == "很抱歉，未找到角色您的角色，请检查您的角色名与服务器是否正确"
      response.should redirect_to(root_path)
    end

    it "should redirect_to root_path with 503 when character is freeze" do
      post :create, :character => { :server => "莉亚德琳", :name => "Sales" }
      flash[:alert].should == "很抱歉，由于该角色长期未活动，已被冻结，无法记录"
      response.should redirect_to(root_path)
    end
  end
end
