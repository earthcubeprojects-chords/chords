{% highlight sh %}
mkdir <chords_config_dir>
cd <chords_config_dir>

# Fetch the control script:
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Initial installation:
python chords_control --config
python chords_control --update
python chords_control --run

# To reconfigure and update:
cd <chords_config_dir>
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
{% endhighlight %}
