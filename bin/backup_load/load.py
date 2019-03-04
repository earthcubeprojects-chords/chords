"""
Load CHORDS databases
"""
import os
import sys
import tempfile
import glob
from collections import namedtuple
import sh
import docker
import json

class ChordsLoadError(Exception):
    """
    raise ChordsLoadError("error msg")
    """
    pass

class ChordsLoad:
    """
    Doc.
    """

    def __init__(self, dump_file, tmp_dir="/tmp"):
        """
        """
        self.dump_file = dump_file
        self.tmp_dir = tempfile.mkdtemp(prefix="chords_load-", dir=os.path.normpath(tmp_dir))
        self.file_paths = {}
        self.docker_containers = {}

        print("*** Dump file unpacking ***")
        self.backup_unpack()

        print("*** Docker ***")
        self.docker_check()
        self.docker_container_status()

        print("*** Loading mysql ***")
        self.load_mysql()

        print("*** Loading influxdb ***")
        self.load_influxdb()

        print("*** Cleanup ***")
        self.docker_container_status()

    def docker_check(self):
        """
        Verify that a CHORDS instance is running correctly.
        """
        self.docker_containers = {}
        self.docker_containers = \
            {c.name: c for c in docker.from_env().containers.list(all=True)}

        err_msg = ""
        for container_name in ["chords_app", "chords_influxdb", "chords_mysql"]:
            if container_name not in self.docker_containers.keys():
                err_msg += "The %s docker container is not present.\n" % (container_name)

        if err_msg:
            raise ChordsLoadError(err_msg)

    def docker_container_status(self):
        """
        Docs.
        """
        for name, container in self.docker_containers.items():
            print(name + ": " + container.status)

    def load_mysql(self, container="chords_mysql", database_name="chords_demo_production"):
        """
        Load the mysql database.
        """
        print ("Container:%s, database:%s" % (container, database_name))
        docker_args = ['exec', '-i', container, '/usr/bin/mysql', database_name]
        print(sh.docker(sh.cat(self.file_paths["mysql"]), docker_args, _err_to_out=True).stdout)

    def load_influxdb(self, container="chords_influxdb", database_name="chords_ts_production"):
        """
        Load the influxdb database.
        """
        print ("Container:%s, database:%s" % (container, database_name))
        #docker_args = ['exec', '-i', container, '/usr/bin/mysql', database_name]
        #print(sh.docker(sh.cat(self.file_paths["mysql"]), docker_args, _err_to_out=True).stdout)


    def backup_unpack(self):
        """
        Docs.
        """
        print("*** Unpacking chords files ***")
        print("Temporary directory: " + self.tmp_dir)
        print(sh.tar('-xzvf', self.dump_file, '-C', self.tmp_dir, _err_to_out=True).stdout)
        self.file_check()

    def file_check(self):
        """
        Determine the dump file names for each database.

        Return an empty string if valid, or an error message if not.
        """
        err_msg = ""
        FileSpec = namedtuple('FileSpec', ['prefix', 'ext'])
        file_types = [FileSpec('mysql', 'sql'),
                      FileSpec('influxdb', 'tar')]
        for file_type in file_types:
            files = glob.glob(self.tmp_dir + "/" + file_type.prefix + "*." + file_type.ext)
            if len(files) == 1:
                self.file_paths[file_type.prefix] = files[0]
            else:
                if len(files) > 1:
                    if err_msg:
                        err_msg += "\n"
                    err_msg += "More than one %s dump file was found: " % (file_type.prefix) + \
                        " ".join([os.path.basename(f) for f in files]) + "."
                else:
                    if err_msg:
                        err_msg += "\n"
                    err_msg += "No %s dump file was found." % (file_type.prefix)
        if err_msg:
            raise ChordsLoadError(err_msg)

    def report(self):
        """
        Provide a report.
        """
        return "Ok"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: load <file_name>")
        exit(1)

    CHORDS_DUMP_FILE = sys.argv[1]

    try:
        load_chords = ChordsLoad(CHORDS_DUMP_FILE)
    except ChordsLoadError as load_exception:
        print("Error processing %s" % (CHORDS_DUMP_FILE))
        print(load_exception)
        exit(1)

    print(load_chords.report())

    exit(0)

