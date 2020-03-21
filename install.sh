
function pre_install() {
  sudo apt update && sudo apt upgrade -y

  sudo apt install -y mc tmux build-essential wget libssl-dev libncurses5-dev \
  libnewt-dev libxml2-dev linux-headers-$(uname -r) libsqlite3-dev uuid-dev git subversion

  # Download sourses
  cd /usr/src/
  sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-17.3.0.tar.gz
  wget --no-check-certificate https://github.com/pbxware/asterisk-sounds-additional/tarball/master -Oadditional-sounds.tar.gz asterisk-17.3.0.tar.gz
  sudo rm -f asterisk-17*.gz
}

function src_install() {
  cd /usr/src/asterisk-17*/

  # Mp3 support
  sudo contrib/scripts/get_mp3_source.sh

  #Install the dependencies:
  sudo contrib/scripts/install_prereq install

  # Compile and install the asterisk:
  #sudo ./configure && sudo make menuselect && sudo make && sudo make install
  sudo ./configure && sudo make && sudo make install
  sudo make samples
}

function configure_logrotete() {
  sudo make /usr/src/asterisk-17*/install-logrotate
  sudo sed -i "s/create 640 root root/create 640 asterisk asterisk/g" /etc/logrotate.d/asterisk
  #statements
}

function configure_asterisk() {

  # Make  work asterisk from user asterisk
  sudo groupadd asterisk
  sudo useradd -d /var/lib/asterisk -g asterisk asterisk
  sudo sed -i 's/#AST_USER="asterisk"/AST_USER="asterisk"/g' /etc/default/asterisk
  # sudo sed -i 's/#AST_GROUP="asterisk"/AST_GROUP="asterisk"/g' /etc/default/asterisk
  # sudo sed -i 's/;runuser = asterisk/runuser = asterisk/g' /etc/asterisk/asterisk.conf
  sudo sed -i 's/;rungroup = asterisk/rungroup = asterisk/g' /etc/asterisk/asterisk.conf
  sudo chown -R asterisk:asterisk /var/spool/asterisk /var/run/asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib/asterisk

  # https://www.clearhat.org/2019/04/12/a-fix-for-apt-install-asterisk-on-ubuntu-18-04/
  sed -i 's";\[radius\]"\[radius\]"g' /etc/asterisk/cdr.conf
  sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cdr.conf
  sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cel.conf
}

function add_russian_music_files() {
  wget --no-check-certificate https://github.com/pbxware/asterisk-sounds-additional/tarball/master -Oadditional-sounds.tar.gz
  sudo mkdir  /var/lib/asterisk/sounds/ru/
  sudo tar -zxvf additional-sounds.tar.gz -C /var/lib/asterisk/sounds/ru/
  rm -f additional-sounds.tar.gz
  sudo  mv  /var/lib/asterisk/sounds/ru/pbxware-asterisk-sounds*/*  /var/lib/asterisk/sounds/ru/
  sudo rm -rf   /var/lib/asterisk/sounds/ru/pbxware-asterisk-sounds-additional*
  sudo chown -R asterisk:asterisk /var/lib/asterisk

}

function start_asterisk() {
  sudo cp /usr/src/asterisk-17*/contrib/systemd/asterisk.service /etc/systemd/system/
  sudo systemctl start asterisk
  sudo systemctl enable asterisk
}


cd /usr/src/asterisk-16*/
suod ./configure
sudo make menuselect
make install
/etc/init.d/asterisk restart
