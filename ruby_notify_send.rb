#!/usr/bin/ruby
# vim:set fileencoding=utf-8 :
#
# options:
#   ignore_message_pattern = Regexp


require 'rubygems'
require 'shellwords'


Config = {
  'ignore_message_pattern' => [nil, 'Regexp'],
}

def weechat_init
  Weechat.register('notify_send', 'anekos', '1.0', 'GPL3', 'ruby + notify-send', '', '')
  Weechat.hook_print('', '', '', 1, 'notify_msg', '')

  Config.each do
    |name, (default, desc)|
    Weechat.config_set_desc_plugin(name, desc)
  end

  # notify('config', Weechat.config_get_plugin('ignore_message_pattern'))

  Weechat::WEECHAT_RC_OK
end

def unhook_notifications (data, signal, message)
  Weechat.unhook(notify_msg)
end

def notify_msg (data, buffer, date, tags, visible, highlight, prefix, message)

  data = {}
  %w[away type channel server].each do
    |key|
    data[key.to_sym] = Weechat.buffer_get_string(buffer, "localvar_#{key}");
  end

  tags = tags.split(/,/)

  return Weechat::WEECHAT_RC_OK unless tags.include?('irc_privmsg')

  # type = channel
  # notify("tags", tags.inspect)

  if ignore_pattern = Weechat.config_get_plugin('ignore_message_pattern')
    return Weechat::WEECHAT_RC_OK if Regexp.new(ignore_pattern.to_s) === message
  end

  notify("#{prefix} on #{data[:channel]}", message)

  Weechat::WEECHAT_RC_OK
end

def notify (title, message)
  system("notify-send #{title.to_s.shellescape} #{message.to_s.shellescape} > /dev/null 2>&1")
end

