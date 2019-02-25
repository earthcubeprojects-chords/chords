"""
Load CHORDS databases
"""
import os
import sys
import tempfile
import glob
from collections import namedtuple
import sh

def invalid_dump_files(tmp_dir):
    """
    Verify that one and only one valid dump file exists for each database.

    Return an empty string if valid, or an error message if not.
    """
    FileSpec = namedtuple('FileSpec', ['prefix', 'ext'])
    retval = ""
    tmp_dir = os.path.normpath(tmp_dir)
    file_types = [FileSpec('mysql','sql'), FileSpec('influxdb','tar')]
    for t in file_types:
        files = glob.glob(tmp_dir + "/" + t.prefix + "*." + t.ext)
        if len(files) > 1:
            if retval:
                retval += "\n"
            retval += "More than one %s dump file was found: " % (t.prefix) + " ".join(files) + "."
        if len(files) < 1:
            if retval:
                retval += "\n"
            retval += "No %s dump file was found." % (t.prefix)
    return retval


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: load <file_name>")
        exit(1)

    chords_dump_file = sys.argv[1]
    tmp_dir = tempfile.mkdtemp(prefix="chords-", dir="/tmp")

    print("*** Unpacking chords files ***")
    print(sh.tar('-xzvf', chords_dump_file, '-C', tmp_dir, _err_to_out=True).stdout)

    err_msg = invalid_dump_files(tmp_dir)
    if err_msg:
        print(err_msg)
        exit(1)

    print("*** Loading mysql ***")


    print("*** Loading influxdb ***")
