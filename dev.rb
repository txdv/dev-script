#!/usr/bin/env ruby

class String
  def starts_with?(chars)
    self.match(/^#{chars}/) ? true : false
  end
end

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

apps = [
  {
    :name  => :mono,
    :exec  => :mono,
    :color => :yellow,
    :version => lambda { return `mono --version`.split(' ')[4] },
  }, {
    :name  => :node,
    :exec  => :node,
    :color => :lightgreen,
    :version => lambda { return `node --version`.strip[1..-1] }
  }, {
    :name    => :ruby,
    :exec    => :ruby,
    :color   => :red,
    :version => lambda { return `ruby --version`.split(' ')[1] }
  }, {
    :name    => :git,
    :exec    => :git,
    :color   => :blue,
    :version => lambda { return `git --version`.strip.split(' ')[2] }
  }, {
    :name    => :vala,
    :exec    => :valac,
    :color   => :lightpurple,
    :version => lambda { return `valac --version`.strip.split(' ')[1] }
  }, {
    :name    => :gcc,
    :exec    => :gcc,
    :color   => :white,
    :version => lambda { return `gcc --version`.strip.split(' ')[2] }
  }, {
    :name   => :clang,
    :exec   => :clang,
    :color  => :lightgray,
    :version => lambda { return `clang --version`.split(' ')[2].strip }
  }, {
    :name   => :ir,
    :exec   => :ir,
    :color  => :lightred,
    :version => lambda { return `ir --version`.split(' ')[1].strip }
  }, {
    :name    => :rust,
    :exec    => :rustc,
    :color   => :lightred,
    :version => lambda { return `rustc --version`.split(' ')[1].strip }
  }
]

def colorize(normal, accent, symbols, str)
  return accent + str.gsub(/[#{symbols}]/) { |arg| normal + arg + accent }
end


pre = "#{color.lightgreen}#{esc.username}#{color.white}@#{color.purple}#{esc.host}#{color.white}:";

str = apps.collect do |app|
  name = app[:name]
  which = `which #{app[:exec]}`
  next if which.length == 0
  next if which.starts_with?("/usr/bin/")
  version = app[:version].call
  colorize(color.white, color[app[:color]], "\.", "#{name}-#{version}")
end.reject { |x| x == nil }.join("#{color.white}:")

res = pre + str + "#{color.white}: #{color.blue}#{esc.pwd} #{color.lightgreen}$#{color.nc} "

vars = { PS1: res }
vars.each do |key, value|
  puts "#{key} #{value}|"
end
