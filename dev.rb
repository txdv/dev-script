#!/usr/bin/env ruby

require 'active_support/core_ext/hash/keys'
require 'yaml'

class ColorHash < Hash
  def initialize(hash)
    super @hash
    @hash = hash
  end

  def method_missing(arg)
    ret = @hash[arg]
    if ret.is_a?(Hash)
      return ColorHash.new(ret)
    else
      return ret
    end
  end

  def [](key)
    @hash[key]
  end
end

h = {
  :day       => '\\d',
  :host      => '\\h',
  :hostname  => '\\H',
  :jobs      => '\\j',
  :termdev   => '\\l',
  :newline   => '\\n',
  :nl        => '\\n',
  :cr        => '\\r',
  :shell     => '\\s',
  :time24    => '\\t',
  :time12    => '\\T',
  :time      => '\\@',
  :stime24   => '\\A',
  :username  => '\\u',
  :version   => '\\v',
  :rversion  => '\\V',
  :pwd       => '\\w',
  :shortpwd  => '\\W',
  :history   => '\\!',
  :number    => '\\#',
  :backslash => '\\\\',

  :color    => {
    :black       => '\\[\\033[00;30m\\]',
    :blue        => '\\[\\033[00;34m\\]',
    :green       => '\\[\\033[00;32m\\]',
    :cyan        => '\\[\\033[00;36m\\]',
    :red         => '\\[\\033[00;31m\\]',
    :purple      => '\\[\\033[00;35m\\]',
    :brown       => '\\[\\033[00;33m\\]',
    :lightgray   => '\\[\\033[00;37m\\]',
    :darkgray    => '\\[\\033[01;30m\\]',
    :lightblue   => '\\[\\033[01;34m\\]',
    :lightgreen  => '\\[\\033[01;32m\\]',
    :lightcyan   => '\\[\\033[01;36m\\]',
    :lightred    => '\\[\\033[01;31m\\]',
    :lightpurple => '\\[\\033[01;35m\\]',
    :yellow      => '\\[\\033[01;33m\\]',
    :white       => '\\[\\033[01;37m\\]',
    :nc          => '\\[\\033[00m\\]'
  }
}

esc = ColorHash.new(h)
color = esc.color

apps = YAML::load_file('dev.yaml').map(&:symbolize_keys)

def colorize(normal, accent, symbols, str)
  return accent + str.gsub(/[#{symbols}]/) { |arg| normal + arg + accent }
end


pre = "#{color.lightgreen}#{esc.username}#{color.white}@#{color.purple}#{esc.host}#{color.white}:";

str = apps.collect do |app|
  name = app[:name]
  which = `which #{app[:exec]}`
  next if which.length == 0
  next if which.start_with?("/usr/bin/")
  version = `#{app[:version]}`.strip
  colorize(color.white, color[app[:color].to_sym], "\.", "#{name}-#{version}")
end.reject { |x| x == nil }.join("#{color.white}:")

res = pre + str + "#{color.white}: #{color.blue}#{esc.pwd} #{color.lightgreen}$#{color.nc} "

vars = { PS1: res }
vars.each do |key, value|
  puts "#{key} #{value}|"
end
