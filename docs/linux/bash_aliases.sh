# Some aliases if you come from the Windows world
echo ''
echo " - Coming from Windows? - "
alias ipconfig='ifconfig'
echo "Use 'ipconfig' for ifconfig"
alias cls='clear'
echo "Use 'cls' to clear console"

# Other usefull aliases
echo ''
echo " - Other tools - "
alias reloadaliases='. ~/.bash_aliases'
echo "Use 'reloadaliases' to reload aliases (current file)"
alias profile='code ~/.bashrc'
echo "Use 'profile' to edit profile (.bashrc file)"
alias pong='ping -c 10'
echo "Use 'pong' to ping (10 times)"
alias version='lsb_release -a'
echo "Use 'version' to get your OS version"

echo ''
echo 'Done. Got get some shit done.'
echo ''

# Move to home directory
cd ~