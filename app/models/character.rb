# coding: utf-8

require 'open-uri'

class Character < ActiveRecord::Base
  has_many :histories

  default_scope limit(20)

  validates :name, :presence => true, :uniqueness => true
  validates :server, :presence => true

  def fetch_armory(new_character)
    begin
      url = URI.escape("http://www.battlenet.com.cn/wow/zh/character/#{server}/#{name}/advanced")
      doc = Nokogiri::HTML.parse(open(url), nil, "utf-8")

      # check last update first
      last_update = doc.at_css('.summary-lastupdate').text.match(/\d{4}\/\d{2}\/\d{2}/)[0]
      unless new_character
        return ['304', 'Not Modifiy'] if already_lastest?(last_update)
      end

      remove_sections(doc, "#header", "#footer", "#service")
      final_page = fix_url(doc)
      target_path, file_path =  make_path

    # doc.write_to(open(file_path, 'w'))
      File.open(file_path, "w") do |f|
        f.write final_page
      end

      make_new_history(doc, target_path, last_update)
      ['200', 'Successful']

    rescue OpenURI::HTTPError => e
#      logger.debug e.message
      if e.message.start_with?('Timeout')
        logger.debug e.message
        retry
      end
      return e.message.start_with?('404') ? ['404', "Can't find Character"]: ['503', "You Character is freeze"]
    end
  end

  private
  # 删除原页面中的导航
  def remove_sections(doc, *sections)
    sections.each do |section|
      doc.at_css(section).remove
    end
  end

  def already_lastest?(last_update)
    year_month_day = last_update.split('/').map(&:to_i)
    last_update_from_page = Date.new(year_month_day[0], year_month_day[1], year_month_day[2])
    self.last_update >= last_update_from_page
  end

  def fix_url(doc)
    doc.css('a').each do |a|
      a['href'] = "http://www.battlenet.com.cn" + a['href']
    end

  # replace css url
    doc.css('link').each do |l|
      if l['rel'] == 'stylesheet'
        l['href'] = "http://www.battlenet.com.cn" + l['href']
      end
    end

  # replace background image
    doc.to_s.sub!("/wow/static/images/character/summary/", "http://www.battlenet.com.cn/wow/static/images/character/summary/")
  end

  def make_path
    t  = Date.today
    y, m, d = t.year, t.month, t.day

    FileUtils.makedirs("public/zh/#{server}/#{name}/#{y}/#{m}")
    target_path = "/zh/#{server}/#{name}/#{y}/#{m}/#{d}.html"
    [target_path, "public" + target_path]
  end

  def make_new_history(doc, target_path, last_update)  
    histories << History.new(target_page: target_path)
    self.race = doc.at_css(".race").text
    self.klass = doc.at_css(".class").text
    self.klass_color = doc.at_css(".under-name").attributes["class"].value.split.last
    self.level = doc.at_css(".level").text.to_i
    self.leveling = false if self.level == 85
    self.achievements = doc.at_css(".achievements").text.to_i
    self.last_update = last_update
    save
  end
end
