echo "Starting setup script..."

# variables
script_path="/usr/local/bin/"
log_path="/var/log/SysMonitor/"

# Install log script
echo "Copying SysMonitor.sh to ${script_path}"
sudo mkdir -p $script_path
sudo cp ./SysMonitor.sh $script_path
sudo chmod +x "${script_path}SysMonitor.sh"

# Setup log directory and log file
echo "Setting up the log file in ${log_path}SysMonitor.log"
sudo mkdir -p $log_path
sudo touch "${log_path}SysMonitor.log"
sudo chmod o+w $log_path "${log_path}SysMonitor.log"

# Configure cron job
echo "Configuring Cron job to run every minute"
rm ./SysMonitor 2>/dev/null
cat > SysMonitor << EOF
# SysMonitor cron START
* * * * * root ${script_path}SysMonitor.sh "${log_path}SysMonitor.log"
# SysMonitor cron END
EOF

sudo mkdir -p /etc/cron.d
sudo cp -f ./SysMonitor /etc/cron.d/
rm ./SysMonitor 2>/dev/null

echo
echo "Finished"