#!/usr/bin/env bash
set -ex
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

apt-get update
apt-get install -y git-core libmagickwand-dev libraqm-dev python3.10-venv

mkdir -p /opt/iw3
cd /opt/iw3
git clone https://github.com/nagadomi/nunif.git
cd nunif

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
pip3 install -r requirements-torch.txt
pip install -f https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-22.04/ wxpython
python -m iw3.download_models


cat >/opt/iw3/nunif/launcher.sh <<EOL
#!/bin/bash
cd /opt/iw3/nunif/
source venv/bin/activate
export LD_LIBRARY_PATH=/opt/iw3/nunif/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/:/opt/iw3/nunif/venv/lib/python3.10/site-packages/nvidia/cuda_nvrtc/lib/:${LD_LIBRARY_PATH}
python -m iw3.gui
EOL

chmod +x /opt/iw3/nunif/launcher.sh

chown -R 1000:1000 /opt/iw3

cat >/usr/share/applications/iw3.desktop <<EOL
[Desktop Entry]
Version=1.0
Name=IW3
Comment=2D to 3D video converter
TryExec=/opt/iw3/nunif/launcher.sh
Exec=/opt/iw3/nunif/launcher.sh -- %u
#Icon=/opt/Telegram/telegram_icon.png
Terminal=false
StartupWMClass=IW3
Type=Application
Categories=Multimedia;
EOL

chmod +x /usr/share/applications/iw3.desktop
chown 1000:1000 /usr/share/applications/iw3.desktop
cp /usr/share/applications/iw3.desktop $HOME/Desktop/iw3.desktop

