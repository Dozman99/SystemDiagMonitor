echo "Starting uninstall..."

# variables
script_path="/usr/local/bin/SysMonitor.sh"

# Remove cron job
echo "Cancelling Cron job"
sudo rm /etc/cron.d/SysMonitor 2>/dev/null

# Remove log script
echo "Removing script, SysMonitor.sh"
sudo rm -rf $script_path 2>/dev/null

# Remove log directory and log file
echo "Removing log, SysMonitor.log"
sudo rm  -rf $LOG_PATH 2>/dev/null

echo
echo "Operation completed"