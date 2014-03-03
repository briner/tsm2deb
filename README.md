tsm2deb
=======
a script to nicely package tsm for debian


Attention
---------
     .
    /!\   
   / ! \    this will only work to create deb for amd64 
  /  !  \   so, if `uname -m` == 'x86_64', then go for it
 ---------

What it does
------------
It mainly rewraps the rpm file so that you can use it on debian and derivatives. Furthermore, it adds:
 - tsm and tsmjbb init script
 - create entry in the menu for dsmj and dsmc
 - dpkg-reconfigure of the "<ORG_NAME>-<TSM_NAME>-ba" package enable automatically tsm as daemon if dsm.sys and the tsm server are configured for schedule.
 - dsmc and dsmj works also as a normal user.

prerequesite
------------
```
aptitude install sysvinit-utils fakeroot cpio rpm2cpio bash rsync imagemagick
```

usage
-----
 - TSM_DIR=~/packaging/tsm/6.4.1.0
 - download the version 6.4.0.0-TIV-TSMBAC-LinuxX86.tar (try downloading from http://www-01.ibm.com/support/docview.wss?rs=663&uid=swg21239415)
 - untar eg: into ${TSM_DIR}
 - download the script tsm2deb and save it to ~/tsm/6.4.1.0
 - edit the variable defined in define_variable in tsm2deb
 - then type
   cd ${TSM_DIR}
   chmod +x tsm2deb
   ./tsm2deb
   sudo dpkg -i *deb
 - and smile big time

explaination
------------
The script is splitted in:
 - define variable: self explanatory
 - rpm2dir: extract some of the rpms to cpio_<directories>
 - wrap_crypt: create the crypt package
 - wrap_ssl: create the ssl package
 - wrap_ba: create the Backup Agent package
 - wrap_api: create the API package
 - wrap_integration: this part is only needed for the University of Geneva,
   as we have developped code to automate the creation and the management of
   tsm account. So you don't need to care about this part
- all_in_one : this will create a big fat package that will be easier to
  install to the end user if you do not have your own repository.

FAQ
---
- So why did we not wrap the other RPMs ?
    Our decision is based on this document:
    http://publib.boulder.ibm.com/infocenter/tsminfo/v6r3/index.jsp?topic=%2Fcom.ibm.itsm.client.doc%2Ft_inst_linuxx86client.html
 - *filepath* since it brings only filepath.ko for a special kernel
 - *JBB* since it is the daemon based on the filepath.ko
 - *cit* since this looks like a real burden
 - FR since we speak english

Hope it will help.

