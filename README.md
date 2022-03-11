# SysMonitor

Here  is a sample GNU/Linux bash script that monitors a computer system and user activity **regularly** and **logs** key information. The script “SysMonitor.sh” automatically and regularly writes to a log file “SysMonitor.log”.

The log file contains time-stamped detailed information about significant changes to the 

following:

- Users currently logged in

- Current processes

- Top 5 CPU utilising processes 

- Devices plugged in (e.g. USB)

- Disk usage:


    - Overall disk usage


    - The user’s home directory (/home/someuser…)

- Network interfaces and their states

The script extracts key details about the changes to the computer system such as listed above and adds them to an ever-growing log file; the log file consists of easily readable key details following conventional log patterns.
