"""
Load CHORDS databases
"""
import sys
import tempfile
import sh

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: load <file_name>")
        exit(1)

    chords_dump_file = sys.argv[1]
    tmp_dir = tempfile.mkdtemp(prefix="chords-", dir="/tmp")

    print("*** Unpacking chords files ***")
    print(sh.tar('-xzvf', chords_dump_file, '-C', tmp_dir, _err_to_out=True).stdout)

    print("*** Loading mysql ***")


    print("*** Loading influxdb ***")
