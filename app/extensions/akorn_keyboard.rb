class AkornKeyboard

  def self.shift_up(frame)
    # normal portrait height is 216, but this keyboard has a table view upon it which
    # makes it considerably higher...
    heights = { :portrait => 326,
                :portrait_upside_down => 326,
                :landscape_left => 162,
                :landscape_right => 162 }
    keyboard_height = heights[Device.orientation]
    bottom = frame.origin.y + frame.size.height
    screen_height = Device.screen.height
    lowest_visible = screen_height - keyboard_height - 64 # 20 or status bar, 44 for nav bar
    if bottom > lowest_visible
      #puts "Below keyboard: #{bottom}, #{lowest_visible}"
      if bottom > screen_height
        return keyboard_height + 5
      else
        return bottom - lowest_visible
      end
    end
    #puts "Above keyboard: #{bottom}, #{lowest_visible}"
    return 0
  end

end