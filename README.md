idsh
====

Intrusion Detection System using bash and the Systems Package Manager System


How it works
====

The idea behind idsh was, to have an simple IDS based on the tools provided with
every Linux distribution. 

F.e. rpm has the "-V" Parameter to verify the integrity of an package.
dpkg has this feature since Version 1.17 (>= Debian 8).

So all the tools you would probably need are on your system, you just got to use them.



Structure & Modules
====

idsh should be as portable and as modular as possible. That's why the input and output 
is done by "modules"; small scripts that have specific functions and return their output
in a specific way.

A pms (Package Management System) modules has alsways a "pms_run"-function that retruns
the result in the way "rpm -V" does. (See http://www.rpm.org/max-rpm/s1-rpm-verify-output.html).

Then this result is piped to an "output"-Modules "output_run"-function. 
It takes the output of the pms-module and does something with it. 

F.e. the default Module is "raw" which simply prints out everything it gets.
But you also could pase it to a Database or an monitoring System to save or report the data.
