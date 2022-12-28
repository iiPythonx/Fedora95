# Fedora95
### A blast from the past powered by bleeding edge software.
---

Fedora95 is a collection of bash scripts and files which turns an ordinary Fedora (typically [rawhide](https://docs.fedoraproject.org/en-US/releases/rawhide/)) installation into a full desktop environment mimicking [Windows 95](https://en.wikipedia.org/wiki/Windows_95). It can automatically install **and configure** [Chicago95](https://github.com/grassmunk/Chicago95) from scratch on any Fedora install.

### Installation
Easy to use oneliner:
```bash
curl https://iipython.cf/g/Fedora95/install.sh | sudo bash
```
The above command might work for most people, although piping to bash is quite a controversial topic. If you wish to review the [source you're running](https://github.com/iiPythonx/Fedora95/blob/main/install.sh):
```
wget https://iipython.cf/g/Fedora95/install.sh
cat install.sh
```
This will confirm that the source you are piping is the exact same as what's in this repository (as `iipython.cf/g/1/2` is a redirect to `raw.githubusercontent.com/iiPythonx/1/main/2`).

### Uninstallation

As of right now, there isn't a straight forward way of removing **everything** Fedora95 does, although this will remove most of it:
```bash
# Git is included for completion; remove if required
sudo dnf remove git xfce4-panel-profiles qt5-qtstyleplugins -y 

# Purge xfce4 files if not removed already
rm -rf ~/.config/xfce4

# Purge Chicago95
sudo rm -rf /usr/share/themes/Chicago95
sudo rm -rf /usr/share/icons/Chicago95*   # Wildcard hits tux
```
