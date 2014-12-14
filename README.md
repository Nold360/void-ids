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

idsh should be as portable and as modular as possible. That's why the input, filtering and output 
is done by "modules"; small scripts (or even binarys) that take data, do something with it, and
print them out againt.

A pms (Package Management System) modules scans it package database and prints it status out.
The result is formated in the way "rpm -V" does. But using ";" instead of spaces. 
(See http://www.rpm.org/max-rpm/s1-rpm-verify-output.htm).

In the next step the output is piped to one or multiple "filter"-modules, which will do
what there name says. By default it's "none". But you could also use "no_config" to
ignore changed config files.

In the last step the filtered result is piped to one or multiple "output"-Modules. 
It takes the output of the filtered pms-module and does something with it. 

F.e. the default Module is "raw" which simply prints out everything it gets.
But you also could pase it to a Database or an monitoring System to save or report the data.
