class String
  def color256(foreground = nil, background = nil)
    values = []

    if not foreground.nil?
      values += [38, 5, foreground]
    end

    if not background.nil?
      values += [48, 5, background]
    end

    if values.length == 0
      ""
    else
      ansi_escape(values) + self + ansi_clear
    end
  end

  private

  def ansi_escape(values)
    "\033[#{values.join(';')}m"
  end

  def ansi_clear
    "\033[0m"
  end
end

if __FILE__ == $0
  length = `tput cols`.to_i
  256.times do |i|
    print i.to_s.rjust(3).color256(i)
    print ' '
    puts ' '.rjust(length - 4).color256(i, i)
  end
end
