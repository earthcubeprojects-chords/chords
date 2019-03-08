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

class ChordsLoadError(Exception):
    """
    Raise ChordsLoadError("error msg")
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
        self.cleanup()

    def cleanup(self):
        """
        Cleanup.
        """
        print("Removing the temporary directory " + self.tmp_dir)
        print(sh.rm('-rf', self.tmp_dir, _err_to_out=True).stdout)

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
        Print the status of all containers.
        """
        for name, container in self.docker_containers.items():
            print(name + ": " + container.status)

    def load_mysql(self, container="chords_mysql", database_name="chords_demo_production"):
        """
        Load the mysql database.
        """
        print("Container:%s, database:%s" % (container, database_name))
        docker_args = ['exec', '-i', container, '/usr/bin/mysql', database_name]
        print(
            sh.docker(
                sh.cat(self.file_paths["mysql"]), docker_args, _err_to_out=True
            ).stdout
        )

    def load_influxdb(self):
        """
        Load the influxdb database.
        """
        admin_pw = "chords_ec_demo"
        influx_tar_file_base = os.path.basename(self.file_paths["influxdb"])

        print("Loading from " + self.file_paths["influxdb"])
        self.docker_cp(self.file_paths["influxdb"], "chords_influxdb:/tmp/")
        self.docker_bash("chords_influxdb",
                         "cd /tmp && tar -xvf %s" % (influx_tar_file_base))
        print("Dropping influxdb database chords_ts_production")
        self.docker_bash(
            "chords_influxdb",
            "influx -username admin -password %s -execute 'drop database chords_ts_production'"
            % (admin_pw)
        )
        print("Loading databases")
        self.docker_bash(
            "chords_influxdb",
            "influxd restore -portable /tmp/%s" % (influx_tar_file_base.replace(".tar", ""))
        )
        print("Curent influxdb databases:")
        self.docker_bash("chords_influxdb",
                         "influx -username admin -password %s -execute 'show databases'"
                         % (admin_pw))

    def backup_unpack(self):
        """
        Unpack the backup file.
        """
        print("*** Unpacking chords files ***")
        print("Temporary directory: " + self.tmp_dir)
        print(
            sh.tar('-xzvf', self.dump_file, '-C', self.tmp_dir, _err_to_out=True).stdout
        )
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
            files = glob.glob(
                self.tmp_dir + "/" + file_type.prefix + "*." + file_type.ext
            )
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
        msg = """
CHORDS databases have been restored.

CHORDS must be restarted by running:
python chords_control --stop
python chords_control --run
"""
        return msg

    def docker_bash(self, container, script):
        """
        Run shell comands in bash. This allows multiple
        commands to be &&'ed together
        """
        print(
            sh.docker(
                'exec', '-t', container, '/bin/bash', '-c', script, _err_to_out=True
            ).stdout
        )

    def docker_cp(self, src, dest):
        """
        Copy file to/from container.
        """
        print(
            sh.docker('cp', src, dest, _err_to_out=True).stdout
        )


def docker_sh(*args):
    """
    run docker command with the args, and print stdout and stderr.
    """
    print(
        sh.docker(args, _err_to_out=True).stdout
    )


def main():
    """
    Main.
    """

    if len(sys.argv) != 2:
        print("Usage: load <file_name>")
        exit(1)

    chords_dump_file = sys.argv[1]

    try:
        load_chords = ChordsLoad(chords_dump_file)
    except ChordsLoadError as load_exception:
        print("Error processing %s" % (chords_dump_file))
        print(load_exception)
        exit(1)

    print(load_chords.report())


if __name__ == "__main__":

    main()
    exit(0)
