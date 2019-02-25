"""
Load CHORDS databases
"""
import os
import sys
import tempfile
import glob
from collections import namedtuple
import sh

class LoadChords:
    """
    Doc.
    """

    def __init__(self, dump_file, tmp_dir="/tmp"):
        """
        """
        self.dump_file = dump_file
        self.tmp_dir = tempfile.mkdtemp(prefix="chords-", dir=os.path.normpath(tmp_dir))
        self.file_paths = {}
        self.unpack()
        self.valid = self.validate()

    def unpack(self):
        """
        Docs.
        """
        print("*** Unpacking chords files ***")
        print(sh.tar('-xzvf', self.dump_file, '-C', self.tmp_dir, _err_to_out=True).stdout)

    def err(self):
        """
        Docs.
        """
        return self.valid

    def validate(self):
        """
        Verify that one and only one valid dump file exists for each database.

        Determine the dump file names for each database.

        Return an empty string if valid, or an error message if not.
        """
        FileSpec = namedtuple('FileSpec', ['prefix', 'ext'])
        retval = ""
        file_types = [FileSpec('mysql', 'sql'),
                      FileSpec('influxdb', 'tar')]
        for file_type in file_types:
            files = glob.glob(self.tmp_dir + "/" + file_type.prefix + "*." + file_type.ext)
            if len(files) == 1:
                self.file_paths[file_type.prefix] = files[0]
            else:
                if len(files) > 1:
                    if retval:
                        retval += "\n"
                    retval += "More than one %s dump file was found: " % (file_type.prefix) + \
                        " ".join([os.path.basename(f) for f in files]) + "."
                else:
                    if retval:
                        retval += "\n"
                    retval += "No %s dump file was found." % (file_type.prefix)
        return retval

    def load_mysql(self, container="chords_mysql", database_name="chords_demo_production"):
        """
        Load the mysql database.
        """
        docker_args = ['exec', '-i', container, '/usr/bin/mysql', database_name]
        print(sh.docker(sh.cat(self.file_paths["mysql"]), docker_args, _err_to_out=True).stdout)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: load <file_name>")
        exit(1)

    chords_dump_file = sys.argv[1]
    load_chords = LoadChords(chords_dump_file)


    err_msg = load_chords.err()
    if err_msg:
        print(chords_dump_file + ": " + err_msg)
        exit(1)

    print("*** Loading mysql ***")
    load_chords.load_mysql()

    print("*** Loading influxdb ***")
