# gnss2chords

Read a datastream from the UNAVCO GNSS Caster server, and write to a CHORDS portal.

gnss2chords.py will connect to the server for a sepcified GNSS stream, read the
incoming data, and translate into http puts to a CHORDS server.

It was fashioned after an original method which used the Ntripclient2.py coupled with sed.
The parameters are identical to the original implementation.

gnss2chords.py is simply a wrapper around Ntripclient2.py. It provides for:
 * blocking reads from Ntripclient2.py, so that it can be started just once,
   to avoid the multiple restarts in the original implementation. These restarts 
   led to regular data losses.
 * It checks when initially started to make sure that another instance isn't already 
   running, and exits if true. This makes it suitable to be run as a cronjob.
 * It performs consistency checks on data returned from Ntripclient2.py, and will
   only write to CHRDS if there is valid data.
 * The `-t` option will cause it to operate in test mode, where the CHORDS get request is
   printed rather than being sent CHORDS.
   
The shell script run_gnss2chords.sh will run gnss2chords.py for all tzvolcano stations. It
could be run as a cronjob. It needs to edited to provide the caster credentials  and to set
the  directory for the source code.
 
 ## Caveats
  * _At present_, there is a bug in Ntripclient2.py which causes serious performance issues. 
    It goes into some sort of loop while waiting for data, which causes the CPU usage
    to peak at 100%.
  * The original implmentation did not handle N/S latitude correctly. gnss2chords.py
    mimics this behvior, but there is a line of code which can be uncommented to
    enable the correct treatment.
    
 