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
    ArmoryScraper.new(self, new_character) do |scraper|
      if (self.char_status = scraper.char_status) == 200
        self.thumbnail = scraper.thumbnail
        self.race = scraper.race
        self.klass = scraper.klass
        self.guild = scraper.guild
        self.klass_color = scraper.klass_color
        self.level = scraper.level
        self.leveling = scraper.leveling
        self.achievements = scraper.achievements
        self.last_update = scraper.last_update
        self.char_status = scraper.char_status
        save

        histories << History.new(target_page: scraper.path_for_model, record_at: scraper.last_update)
      end
    end
  end
end
