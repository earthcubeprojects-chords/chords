{% highlight sh %} <!--Using Liquid to highlight syntax-->
mkdir -p /var/lib/chords
cd /var/lib/chords

# Fetch the control script:
pip install sh
curl -O -k https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Initial installation:
python chords_control --config
python chords_control --update

# To run CHORDS:
python chords_control --run

# To stop CHORDS:
python chords_control --stop

# To reconfigure and update:
cd /var/lib/chords
curl -O -k  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
{% endhighlight %}
Now point your browser at the IP of the the system. localhost
will often work as the IP, if the browser is on the same system.
<strong>Be sure to use http:// (not https://)</strong>.
