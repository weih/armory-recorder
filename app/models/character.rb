# coding: utf-8

class Character < ActiveRecord::Base
  attr_accessor :char_status
  
  has_many :histories, :dependent => :destroy

  scope :new_char, order("created_at DESC").limit(8)
  scope :random_char, where(leveling: false).order("histories_count DESC")
  scope :leveling, where(leveling: true).order("histories_count DESC, level DESC")
  scope :same_server, lambda { |char| where(server: char.server).order("last_update DESC") }

  validates :name, :presence => true
  validates :server, :presence => true

  def group_histories
    histories.order("record_at").group_by{|t| "#{t.record_at.year} #{t.record_at.month}"}
  end

  ##
  # 通过ArmoryScrap实例获取角色的信息
  def fetch_armory(new_character)
    ArmoryScraper.new(self, new_character) do |doc, options|
      if (self.char_status = options[:char_status]) == 200
        self.thumbnail = "/zh/" + API::BATTLENET.character(server, name)['thumbnail']
        self.race = doc.at_css(".race").text
        self.klass = doc.at_css(".class").text
        if guild = doc.at_css(".guild")
          self.guild = guild.text.strip
        end
        self.klass_color = doc.at_css(".under-name").attributes["class"].value.split.last
        self.level = doc.at_css(".level").text.to_i
        self.leveling = false if self.level == 85
        self.achievements = doc.at_css(".achievements").text.to_i
        self.last_update = options[:last_update]
        save
        
        histories << History.new(target_page: options[:path_for_model], record_at: self.last_update)
      end
    end
  end
end
