yum -y install git ruby
gem install macaddr
git clone https://github.com/openflighthpc/hunter.git /root/hunter

chmod +x /root/hunter/bin
sed -i 's|config.yaml|/root/hunter/bin/client/config.yaml|g' /root/hunter/bin/client/client.rb
echo "ip=$(cat /proc/cmdline)" >> /etc/rc.local
echo "ip=\"${c##*hunter_ip=}\"" >> /etc/rc.local
echo "ip=\"${c%% *}\"" >> /etc/rc.local
