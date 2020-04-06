# Kickstart for Ansible provisioning

A Red Hat Kickstart file for automatic installation and provisioning through Ansible for RHEL and CentOS (and Fedora with modifications).

### Usage

Specify the `inst.ks=` boot flag to point to the location of your Kickstart file, e.g.:
```
inst.ks=http://someserver/ks.cfg
inst.ks=hd:sda1:/ks.cfg
inst.ks=file:/dir/ks.cfg
```
Make sure to add this boot option to your isolinux.cfg when generating a custom image.

The files should be fairly self-explanatory:

###### ks.cfg
The actual Kickstart file. Customize the installation options as needed. Make sure to copy in the private key used for accessing your Git repo.
###### firstboot.sh
This script is embedded in the Kickstart file and is called on first boot using cron. It adds SSH keys for Github, then installs `git` and `ansible`. It then runs `ansible-pull` to provision the server.
Make sure to copy changes to this file back to `ks.cfg`, or edit `%post%` to copy the file from somewhere else, e.g.:
```
%post --nochroot
cp -a /run/install/repo/custom/firstboot.sh /root/firstboot.sh
%end
```
###### firstboot.yml
The Ansible script firstboot.sh pulls. Perform whatever steps you need to provision your server here, and make sure to use the cron module to remove the cronjob set by Kickstart.
