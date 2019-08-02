class PyController < ApplicationController
  def home 
    our_input_text = " heart" 
    @heart = `python lib/assets/python/heart.py "#{our_input_text}"`
  end
end
