#!/bin/sh
log_file=$1
if [ -z "$1" ]; then
    log_file='/var/log/SysMonitor/SysMonitor.log'
fi

# Fetch the currently active users
active_users=$(loginctl list-users --no-legend | wc -l)
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
outer="{ \"active_users\": ${active_users}, \"users\": ["
users=""

for user in $(loginctl list-users --no-legend | sed -E 's/\s+/-/g'); do
    name=$(echo $user | sed -E 's/-[0-9]+-//' | sed -E 's/-//g')
    users="${users} ${name}"
    uid=$(echo $user | sed -E "s/-${name}-//" | sed -E 's/-//g')
    inner="{ \"id\": ${uid}, \"user\": \"${name}\" }, "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer}] }"
log="${timestamp}\tuser-monitor:\tUsers currently logged in:\t${outer}"

echo "${log}" >> $log_file

# Fetch all current proceccess
outer="[ "
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
for p in $(ps -aux --no-headers | sed -E 's/\s/~+~/g'); do
    p=$(echo $p | sed -E 's/~\+~/ /g')
    user=$(echo $p | sed -E 's/^(\S+)\s+.*/\1/g')
    pid=$(echo $p | sed -E 's/^\S+\s+([0-9]+).*/\1/g')
    command=$(echo $p | sed -E 's/^(\S+\s+){10}(.*)/\2/g')

    inner="{ \"user\": \"${user}\", \"pid\": ${pid}, \"command\": \"${command}\" }, "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer} ]"
log="${timestamp}\tprocess-monitor:\tAll current processes:\t${outer}"

echo "${log}" >> $log_file

# Get CPU utilization
outer="[ "
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
for p in $(top -b -n 1 | sed -z -E 's/^([^\n]*\n){7}(([^\n]*\n){5}).*/\2/' | sed -E 's/\s/~+~/g'); do
    p=$(echo $p | sed -E 's/~\+~/ /g')
    user=$(echo $p | sed -E 's/^\s*\S+\s+(\S+).*/\1/g')
    pid=$(echo $p | sed -E 's/^\s*(\S+).*/\1/g')
    cpu=$(echo $p | sed -E 's/^\s*(\S+\s+){8}(\S+).*/\2/g')
    command=$(echo $p | sed -E 's/^\s*(\S+\s+){11}(.*)/\2/g')

    inner="{ \"user\": \"${user}\", \"pid\": ${pid}, \"cpu\": ${cpu}, \"command\": \"${command}\" }, "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer} ]"
log="${timestamp}\tcpu-monitor:\tTop 5 CPU utilizing processes:\t${outer}"

echo "${log}" >> $log_file

# Fetch plugged in devices
outer="[ "
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
for usb in $(lsusb | sed -E 's/\s/~+~/g'); do
    usb=$(echo $usb | sed -E 's/~\+~/ /g')

    inner="\"${usb}\", "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer} ]"
log="${timestamp}\tdevice-monitor:\tDevices plugged in:\t${outer}"

echo "${log}" >> $log_file

#Fetch current disk usage
overall=$(df / -h | sed -z -E 's/[^\n]*\n(\S+\s+){2}(\S+).*/\2/')
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
outer="{ \"overall\": \"${overall}\", \"users\": ["

for user in $(lslogins --noheadings | sed -z -E 's/[^\n]+\n(.*)/\1/' | sed -E 's/\s/~+~/g'); do
    user=$(echo $user | sed -E 's/~\+~/ /g')
    user=$(echo $user | sed -E 's/\S+\s+(\S+).*/\1/')
    size=$(du /home/${user}/ -h -s 2>/dev/null | sed -E 's/^(\S+)\s+.*/\1/g')
    inner="{ \"user\": \"${user}\", \"home_size\": \"${size}\", \"home\": \"/home/${user}\" }, "
    
    # Sort out users without a home directory
    ls /home/${user}/ 2>/dev/null >/dev/null && outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer}] }"
log="${timestamp}\tdisk-usage-monitor:\tDisk usage:\t${outer}"

echo "${log}" >> $log_file

# Fetch network interfaces and their states
outer="[ "
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
for itf in $(ip addr | sed -E -z 's/\n\s+[^\n]+//g' | sed -E 's/\s/~+~/g'); do
    itf=$(echo $itf | sed -E 's/~\+~/ /g')
    if=$(echo $itf | sed -E 's/^\S+\s+([^:]+):.*/\1/g')
    state=$(echo $itf | sed -E 's/^.+state\s+(\S+).*/\1/g')

    inner="{ \"interface\": \"${if}\", \"state\": \"${state}\" }, "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer} ]"
log="${timestamp}\tnetwork-interface-monitor:\tNetwork interfaces and their states:\t${outer}"

echo "${log}" >> $log_file

# Fetch protocols running on the network
outer="[ "
timestamp=$(date | sed -E 's/.{4}(.{15}).*/\1/')
ptc='~'
for p in $(netstat -a | sed -E -z 's/(^\n)*Active([^\n]*\n){2}|[^\n]*Proto[^\n]*\n//g' | sed -E 's/\s/~+~/g'); do
    p=$(echo $p | sed -E 's/~\+~/ /g')
    proto=$(echo $p | sed -E 's/^\s*(\S+).+/\1/')
    ptc=$(echo $ptc | sed -E "s/~+${proto}~+/~/g")
    ptc="$ptc$proto~"
done
for proto in $(echo $ptc | sed -E 's/~/ /g'); do
    inner="\"$proto\", "
    outer="${outer}${inner}"
done
outer=$(echo $outer | sed -E 's/,\s*$//')
outer="${outer} ]"
log="${timestamp}\tnetwork-protocol-monitor:\tAll Protocols running on the network:\t${outer}"

echo "${log}" >> $log_file

