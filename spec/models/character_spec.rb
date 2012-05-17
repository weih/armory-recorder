# coding: utf-8
require 'spec_helper'

describe Character do
  let(:new_char) { Character.new(name: "Bigdaddy", server: "戈提克") }

  context "fetch_armory method" do
    it "should create new character with a new history" do
      new_char.fetch_armory(true)
      new_char.save
      new_char.histories.count.should == 1
      Character.count.should == 1
    end
    
    it "should create new character with correct attributes" do
      new_char.fetch_armory(true)
      new_char.name.should == "Bigdaddy"
      new_char.server.should == "戈提克"
      new_char.level.should == 39
      new_char.leveling.should == true
      new_char.race.should == "矮人"
      new_char.klass.should == "牧师"
      new_char.klass_color.should == "color-c5"
      new_char.last_update.should == Date.new(2012, 02, 01)
    end

    it "should update character last_update attribute with correct time" do
      new_char.last_update = Date.new(2012, 01, 01)
      new_char.fetch_armory(false)
      new_char.last_update.should == Date.new(2012, 02, 01)
      new_char.histories.count.should == 1
    end

    it "should not update character last_update attribute when armory is lastest" do
      new_char.last_update = Date.new(2012, 02, 01)
      new_char.fetch_armory(false)
      new_char.histories.count.should == 0
    end
  end

  it "should create new character with the same name but the server" do
    new_char.save
    another_new_char = Character.new(name: "Bigdaddy", server: "血吼")
    another_new_char.save
    Character.count.should == 2
  end
end
