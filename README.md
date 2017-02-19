# vagrant-aws-linux
Creation of an Amazon Linux image for use with Vagrant/VirtualBox

I have found myself testing chef recipes (and other stuff) that required use of an Amazon Linux system to fully validate, however I did not find one readily available to run locally.

AWS EC2 instances run on top of Xen on pretty generic virtual hardware definition (will post details later).
For HVM type instances, which are full VMs (ie. like a physical system), the boot process is standard, involving a BIOS, a boot loader, a boot sector, (etc) and associated software.

Based on this, I decieded to make an imagea available for my local testing.
After messing up a bit with the configuraitons, I successfully exported a disk image (with dd) and imported that into VirtualBox, then created a vagrant image which served my purpose.

I consider this may be useful for more people in similar situations as this gives the following benefits:
  - enable local development on AWS linux
  - save costs (do not launch a new AWS instance to test each change, even if you can do spot)
  - testing integrity (easily start clean on each test)
  - internet-less enabled (do you always, 100% of the time, have a reliable internet connection?)


I do not dislike bash, neither I love it, but due to time constraints it was the safe option, hence most of the glue it is shell. You are welcome to translate/update/modify stuff into python or ruby (others welcome), as I do plan to do it (most likely ruby due to Vagrant) when time allows.


Thanks for reading and, for those who are familiar (and I'm stealing the phrase); work hard, have fun, make history!
