
require "rubypython" 

RubyPython.start python_exe: `which python`.chomp 
pyfile=RubyPython.import "#{Rails.root}/app/assets/convert_to_json.py" 
puts pyfile.dumps "This worked!" 
RubyPython.stop

