# coding: utf-8
require 'open-uri'

class ArmoryScraper
  attr_accessor :thumbnail, :race, :klass, :guild, :klass_color, :level, :leveling, :achievements, :last_update, :path_for_model, :char_status

  def initialize(char, new_character,  &block)
    @char = char
    @new_character = new_character
    scraping

    yield self
  end
  
  def scraping
    begin
      url = URI.escape("http://www.battlenet.com.cn/wow/zh/character/#{@char.server}/#{@char.name}/advanced")
      @doc = Nokogiri::HTML.parse(open(url), nil, "utf-8")

      # check last update first
      @last_update = Date.parse(@doc.at_css('.summary-lastupdate').text.match(/\d{4}\/\d{2}\/\d{2}/)[0])

      # 通过@new_character来判断该角色是不是最新登记
      # 最新登记的角色不检查最后更新时间
      unless @new_character
        if already_lastest?
          @char_status = 304
          return
        end
      end

      remove_sections("#header", "#footer", "#service")

      fetch_profile_wrapper
      fetch_avatar
      fetch_page

      scrap_information

      @char_status = 200
    rescue OpenURI::HTTPError => e
      if e.message.start_with?('Timeout')
        retry
      end
      @char_status = e.message.start_with?('404') ? 404 : 503
    end
  end


  private
  ##
  # 删除原页面中不必要的部分
  def remove_sections(*sections)
    sections.each do |section|
      @doc.at_css(section).remove
    end
    @doc.css("script").remove
    @doc.at_css('link').remove
  end

  ##
  # 通过角色最后更新时间来判断是否需要更新
  def already_lastest?
    self.last_update >= @last_update
  end

  def fix_url
    @doc.css('a').each do |a|
      a['href'] = "http://www.battlenet.com.cn" + a['href']
    end

    @doc.css('link').each do |link|
      if link['rel'] == 'stylesheet'
        link['href'] = "http://www.battlenet.com.cn" + link['href']
      end
    end

  # replace background image and profile_wrapper
    page_source = @doc.to_s.sub("/wow/static/images/character/summary/", "http://www.battlenet.com.cn/wow/static/images/character/summary/")
    page_source.sub!(/http:\/\/www.battlenet.com.cn\/static-render\/cn\/(.+?)\/(\d+)/, "/zh/\\1/\\2/#{@last_update.year}/#{@last_update.month}/#{@last_update.day}")

    page_source
  end

  ##
  # 获取角色人物造型图
  def fetch_profile_wrapper
    profile_path = /profile-wrapper\s{\sbackground-image:\surl\("(.*)"/.match(@doc)[1]
    profile_wrapper_path = profile_path.split('?')[0]
    url_array = profile_wrapper_path.split('/')
    profile_name = url_array.last
    dir = "public/zh/#{url_array[5]}/#{url_array[6]}/#{@last_update.year}/#{@last_update.month}/#{@last_update.day}/"
    FileUtils.makedirs(dir)

    file_path = dir + profile_name
#    profile_wrapper_path += "?alt=/wow/static/images/2d/profilemain/race/2-0.jpg"

    fetch_image(profile_wrapper_path, file_path)
  end

  ##
  # 获取角色头像
  def fetch_avatar
    thumbnail = API::BATTLENET.character(@char.server, @char.name)['thumbnail']
    image_url = "http://www.battlenet.com.cn/static-render/cn/#{thumbnail}"
    file_path = "public/zh/#{thumbnail}"

    fetch_image(image_url, file_path)
  end

  ##
  # 获取图片
  # 由于官方对同一IP短时间内获取的图片数量有限制
  # 所以需要多次获取来获得图片
  # FIXME: 使用Thread
  def fetch_image(url, file_path)
    times = 0

    begin
      open(url) do |img|
        File.open(file_path, "w") do |f|
          f.write img.read.force_encoding("UTF-8")
        end
      end
    rescue OpenURI::HTTPError => e
      times += 1
      retry if times < 5
    ensure
      if times >= 5
        open(url) do |img|
          File.open(file_path, "w") do |f|
            f.write img.read.force_encoding("UTF-8")
          end
        end
      end
    end
  end


  ##
  # 将角色英雄榜HTML页面写入本地文件系统
  def fetch_page
    y, m, d = @last_update.year, @last_update.month, @last_update.day

    FileUtils.makedirs("public/zh/#{@char.server}/#{@char.name}/#{y}/#{m}")
    @path_for_model = "/zh/#{@char.server}/#{@char.name}/#{y}/#{m}/#{d}.html"
    path_for_system = "public#{@path_for_model}"

    final_page = fix_url
    
    File.open(path_for_system, "w") do |f|
      f.write final_page
    end
  end

  ##
  # 保存角色信息至scraper
  def scrap_information    
    self.thumbnail = "/zh/" + API::BATTLENET.character(@char.server, @char.name)['thumbnail']
    self.race = @doc.at_css(".race").text
    self.klass = @doc.at_css(".class").text
    if guild = @doc.at_css(".guild")
      self.guild = guild.text.strip
    end
    self.klass_color = @doc.at_css(".under-name").attributes["class"].value.split.last
    self.level = @doc.at_css(".level").text.to_i
    self.leveling = false if self.level == 85
    self.achievements = @doc.at_css(".achievements").text.to_i
    self.last_update = @last_update
   end
end
