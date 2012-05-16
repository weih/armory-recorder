# coding: utf-8

require 'open-uri'

class Character < ActiveRecord::Base
  has_many :histories, :dependent => :destroy

  default_scope limit(8)

  validates :name, :presence => true
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
      remove_js(doc)
      get_profile_wrapper(doc)
      final_page = fix_url(doc)
      target_path, file_path =  make_path

    # doc.write_to(open(file_path, 'w'))
      File.open(file_path, "w") do |f|
        f.write final_page
      end

      make_new_history(doc, target_path, last_update)
      return ['200', '角色登记成功']

    rescue OpenURI::HTTPError => e
#      logger.debug e.message
      if e.message.start_with?('Timeout')
        logger.debug e.message
        retry
      end
      return e.message.start_with?('404') ? ['404', "很抱歉，未找到角色您的角色，请检查您的角色名与服务器是否正确"]: ['503', "很抱歉，由于该角色长期未活动，已被冻结，无法记录"]
    end
  end

  private
  # 删除原页面中的导航
  def remove_sections(doc, *sections)
    sections.each do |section|
      doc.at_css(section).remove
    end
  end

  def remove_js(doc)
    doc.css("script").remove
  end

  def already_lastest?(last_update)
    year_month_day = last_update.split('/').map(&:to_i)
    last_update_from_page = Date.new(year_month_day[0], year_month_day[1], year_month_day[2])
    self.last_update >= last_update_from_page
  end

  def fix_url(doc)
    doc.at_css('link').remove

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
    doc.to_s.sub!("/wow/static/images/character/summary/", "http://www.battlenet.com.cn/wow/static/images/character/summary/").sub!("http://www.battlenet.com.cn/static-render/cn", "/zh")
  end

  def get_profile_wrapper(doc)
    profile_path = /profile-wrapper\s{\sbackground-image:\surl\("(.*)"/.match(doc)[1]
    url_array = profile_path.split('?')[0].split('/')
    profile_name = url_array.last
    dir = "public/zh/#{url_array[5]}/#{url_array[6]}/"
#    logger.debug dir
    FileUtils.makedirs(dir)
    file_path = dir + profile_name
    logger.debug file_path
    open(profile_path) do |page|
      logger.debug profile_path
      File.open(file_path, "w") do |f|
#        logger.debug file_path
        f.write page.read.force_encoding("UTF-8")
      end
    end
  end

  def make_path
    t  = Date.today
    y, m, d = t.year, t.month, t.day

    FileUtils.makedirs("public/zh/#{server}/#{name}/#{y}/#{m}")
    target_path = "/zh/#{server}/#{name}/#{y}/#{m}/#{d}.html"
    [target_path, "public" + target_path]
  end

  def make_new_history(doc, target_path, last_update)  
    histories << History.new(target_page: target_path, record_at: last_update)
    self.thumbnail = "http://www.battlenet.com.cn/static-render/cn/" + API::BATTLENET.character(server, name)['thumbnail']
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
