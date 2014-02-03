supervisor-tools
================

Some simple bash scripts I use with supervisord, usually within docker containers. Currently this includes only one script, wait-for-daemons.sh which can be used to pause execution of a script until supervisord has started a specific program or set of programs.

Usage
-----

The following bash script will only ouput "RESTARTED" once sshd has finished being restarted by supervisord:

    #!/bin/bash
    supervisorctl restart sshd
    ./wait-for-daemons.sh sshd
    echo "RESTARTED"

You can also specify multiple programs to wait for:

    ./wait-for-daemons.sh sshd apache2

This script makes use of supervisorctl. If supervisorctl is not in your path or you want to specify its path then use the optional "p" option:

    ./wait-for-daemons -p /usr/sbin/supervisorctl sshd

If a program is not configured to be handled by supervisord then it will be ignored and wait-for-daemons.sh will exit (unless another program you asked it to wait for isn't running yet.).

If you find the script too noisy you can just output to null:

    ./wait-for-daemons.sh sshd > /dev/null

Todo
----

* Error handling.
* Automated tests.
* Add an "all" option that will wait for all programs configured under supervisord.
* Perhaps a silent option so you do not have to output to null.
* This has only been tested using supervisord version 3.0a8 on ubuntu precise. I suspect its not very robust against updates to supervisord/supervisorctl.
* Allow additional parameters to be passed when calling supervisorctl. This may be needed for authentication.