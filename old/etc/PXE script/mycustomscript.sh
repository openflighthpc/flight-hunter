yum -y groupinstall "Development Tools"
yum -y install openssl-devel
wget http://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.3.tar.gz
tar xvfvz ruby-2.6.3.tar.gz
cd ruby-2.6.3
./configure
make
make install
gem install bundler
git clone -b develop https://github.com/openflighthpc/flight-hunter.git /root/hunter
git clone https://github.com/openflighthpc/flight-inventory-data-gatherer.git /root/gatherer
chmod +x /root/hunter/bin
chmod +x /root/gatherer/build
cd /root/inventory
bundle install
mkdir var/store/default
cd /root/hunter
bundle install
touch /root/hunter.sh
cat <<EOT >> /root/hunter.sh
#!/bin/bash
cd /root/gatherer/build
./gather-data-bundled.sh payload
chmod 755 /tmp/payload.zip
od -An -vtx1 /tmp/payload.zip > /tmp/payload.txt
/root/hunter/bin/hunter.rb send --file /tmp/payload.txt
EOT
chmod +x /root/hunter.sh
chmod +X /etc/rc.d/rc.local
echo "export HUNTERIP=\$(cat /proc/cmdline | sed -e 's/^.*hunter_ip=//' -e 's/ .*$//')" >> /etc/rc.d/rc.local
echo "/root/hunter/bin/hunter.rb modify-ip \$HUNTERIP" >> /etc/rc.d/rc.local
echo "/root/hunter.sh" >> /etc/rc.d/rc.local
systemctl enable rc-local.service
