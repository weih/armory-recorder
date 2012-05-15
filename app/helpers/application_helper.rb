# coding: utf-8
module ApplicationHelper
  def format_date(date)
    year, month = date.split
    "#{year}年#{month}月"
  end

  def collapse_show?(index)
    "in" if index == 0
  end

  # copy from ruby-china application_helper.rb
  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type == :notice
      type = :error if type == :alert
      text = content_tag(:p, message, :class => "#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end
end
