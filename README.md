# vagrant-aws-linux
Creation of an Amazon Linux image for use with Vagrant/VirtualBox

I have found myself testing chef recipes (and other stuff) that required use of an Amazon Linux system to fully validate, however I did not find one readily available to run locally.

AWS EC2 instances run on top of Xen, on pretty generic virtual hardware definition (see details at the bottom).
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



### AWS EC2 Instance hardware info (obtained from a t2.micro)
This is (pretty much) a Pentium II era platform setup (aside from the Xen device).

```
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE [Natoma/Triton II]
00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 01)
00:02.0 VGA compatible controller: Cirrus Logic GD 5446
00:03.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)
```

