# coding: utf-8

require 'open-uri'

class Character < ActiveRecord::Base
  has_many :histories, :dependent => :destroy

  scope :new_char, order("created_at DESC").limit(8)
  scope :random_char, where(leveling: false).order("histories_count DESC")
  scope :leveling, where(leveling: true).order("histories_count DESC, level DESC")
  scope :same_server, lambda { |char| where(server: char.server).order("last_update DESC") }

  validates :name, :presence => true
  validates :server, :presence => true

  def fetch_armory(new_character)
    begin
      url = URI.escape("http://www.battlenet.com.cn/wow/zh/character/#{server}/#{name}/advanced")
      doc = Nokogiri::HTML.parse(open(url), nil, "utf-8")

      # check last update first
      last_update = Date.parse(doc.at_css('.summary-lastupdate').text.match(/\d{4}\/\d{2}\/\d{2}/)[0])
      
      unless new_character
        return [304, 'Not Modifiy'] if already_lastest?(last_update)
      end

      remove_sections(doc, "#header", "#footer", "#service")
      remove_js(doc)

      set_profile_wrapper_and_avatar(doc, last_update)
      target_path, file_path =  make_path(last_update)
      
      final_page = fix_url(doc, last_update)

      File.open(file_path, "w") do |f|
        f.write final_page
      end

      make_new_history(doc, target_path, last_update)

      return [200, '角色登记成功']

    rescue OpenURI::HTTPError => e
      puts e.message
      logger.debug "Got a Message From character.rb : #{e.message}"
      if e.message.start_with?('Timeout')
        logger.debug "Got a Timeout Message character.rb : #{e.message}"
        retry
      end
      return e.message.start_with?('404') ? [404, "很抱歉，未找到角色您的角色，请检查您的角色名与服务器是否正确"]: [503, "很抱歉，由于该角色长期未活动，已被冻结，无法记录"]
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
    # last_update_from_page = Date.parse(last_update)
    self.last_update >= last_update
  end

  def fix_url(doc, last_update)
    doc.at_css('link').remove

    doc.css('a').each do |a|
      a['href'] = "http://www.battlenet.com.cn" + a['href']
    end

  # replace css url
    doc.css('link').each do |link|
      if link['rel'] == 'stylesheet'
        link['href'] = "http://www.battlenet.com.cn" + link['href']
      end
    end

  # replace background image
    page = doc.to_s.sub("/wow/static/images/character/summary/", "http://www.battlenet.com.cn/wow/static/images/character/summary/")

    page.sub!(/http:\/\/www.battlenet.com.cn\/static-render\/cn\/(.+?)\/(\d+)/, "/zh/\\1/\\2/#{last_update.year}/#{last_update.month}/#{last_update.day}")

    page
  end

  def set_profile_wrapper_and_avatar(doc, last_update)
    profile_path = /profile-wrapper\s{\sbackground-image:\surl\("(.*)"/.match(doc)[1]
    image_url = profile_path.split('?')[0]
    logger.debug image_url
    url_array = image_url.split('/')
    profile_name = url_array.last
    dir = "public/zh/#{url_array[5]}/#{url_array[6]}/#{last_update.year}/#{last_update.month}/#{last_update.day}/"
    FileUtils.makedirs(dir)
    file_path = dir + profile_name
    
    image_url += "?alt=/wow/static/images/2d/profilemain/race/2-0.jpg"
    fetch_profile_image(image_url, file_path)
    fetch_avatar_image
  end

  def fetch_profile_image(profile_path, file_path)
    image_sha = ""
    times = 0
    page = ""

    open(profile_path) do |f|
      page = f.read
      image_sha = Digest::SHA1.hexdigest(page)
    end
    
    logger.debug image_sha
    logger.debug API::DEFAULT_ORC_IMAGE_HASH

    while (API::DEFAULT_ORC_IMAGE_HASH == image_sha) & (times < 5)
      logger.debug "Refetch Image Start, Now iamge_sha is: #{image_sha}"
      open(profile_path) do |f|
        page = f.read
        image_sha = Digest::SHA1.hexdigest(page)          
      end
      times += 1
      logger.debug "Refetch Image End, Now iamge_sha is: #{image_sha}"
    end
    
    File.open(file_path, "w") do |f|
      f.write page.force_encoding("UTF-8")
    end
  end

  def fetch_avatar_image
    thumbnail = API::BATTLENET.character(server, name)['thumbnail']
    image_url = "http://www.battlenet.com.cn/static-render/cn/" + thumbnail
    file_path = "public/zh/#{thumbnail}"
    times = 0

    begin
      open(image_url) do |img|
        File.open(file_path, "w") do |f|
          f.write img.read.force_encoding("UTF-8")
        end
      end
    rescue OpenURI::HTTPError => e
      logger.debug times
      times += 1
      retry if times < 5
    ensure
      if times >= 5
        open(image_url) do |img|
          File.open(file_path, "w") do |f|
            f.write img.read.force_encoding("UTF-8")
          end
        end
      end
    end
  end

  def make_path(last_update)
    # last_update = Date.parse(last_update)
    y, m, d = last_update.year, last_update.month, last_update.day

    FileUtils.makedirs("public/zh/#{server}/#{name}/#{y}/#{m}")
    target_path = "/zh/#{server}/#{name}/#{y}/#{m}/#{d}.html"

    [target_path, "public" + target_path]
  end

  def make_new_history(doc, target_path, last_update)
    histories << History.new(target_page: target_path, record_at: last_update)
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
    self.last_update = last_update
    save
  end
end
