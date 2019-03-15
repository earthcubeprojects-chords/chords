""" Utilities for docker interaction. """

import sh

class ChordsLoadError(Exception):
    """ Raise ChordsLoadError("error msg"). """
    pass

def docker_bash(container, script):
    """
    Run shell comands in a docker bash instance.

    This allows multiple commands to be &&'ed together.
    """

    return docker_sh('exec', '-t', container, '/bin/bash', '-c', script)

def docker_sh(*args):
    """ Run a docker command with the args, printing stdout and stderr. """

    try:
        result = sh.docker(args, _err_to_out=True).stdout
        return str(result)
    except Exception as sh_err:
        raise ChordsLoadError(sh_err)

def docker_cp(src, dest):
    """
    Copy a file to/from container.

    src and/or dest will specify a container prefix when appropriate, e.g.
        docker_cp(database.sql chords_mysql:/tmp)
    """

    docker_sh('cp', src, dest)
