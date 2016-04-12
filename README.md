tsm2deb
=======
A script to nicely package tsm for debian and derivatives (Mint, Ubuntu…)

! dsmj is broken on jessie, but works with oracle-java


Attention
---------
this will only work to create deb for amd64
so, if
```
uname -m == 'x86_64'
```
then go for it

What it does
------------
It mainly rewraps the rpm file so that you can use it on debian and derivatives. Furthermore, it adds:
 - tsm and tsmjbb init script
 - create entry in the menu for dsmj and dsmc
 - dpkg-reconfigure of the "<ORG_NAME>-<TSM_NAME>-ba" package enable automatically tsm as daemon if dsm.sys and the tsm server are configured for schedule.
 - dsmc and dsmj works also as a normal user.

prerequesite
------------
```bash
aptitude install sysvinit-utils fakeroot cpio rpm2cpio bash rsync imagemagick unzip git
```

usage
-----
 - setup
```bash
TSM_DIR=~/packaging/tsm/7.1.3
mkdir -p ${TSM_DIR}
cd ${TSM_DIR}
```

 - download tsm2deb
```bash
# clone the 7.1.3-systemd branch
git clone -b 7.1.3-systemd https://github.com/briner/tsm2deb ./
```

- download tsm from ibm
```
wget ftp://public.dhe.ibm.com/storage/tivoli-storage-management/maintenance/client/v7r1/Linux/LinuxX86/BA/v713/7.1.3.0-TIV-TSMBAC-LinuxX86.tar

# untar it:
tar -xf 7.1.3.0-TIV-TSMBAC-LinuxX86.tar
```
 - edit the variable defined in define_variable in tsm2deb.conf
  - TSM_ROOT
  - TSM_NAME
  - TSM_VER
  - SHORT_ORG
  - OPT_PATH
  - EMAIL_MAINTAINER
  - all the drpm which should match the ```ls -l ${TSM_DIR}/*.rpm```
  - all the ddeb_ver which should be 0 when doing your first packaging
    and the get increased by one at each new version.
 - wrap them all
```bash
cd ${TSM_DIR}
chmod +x tsm2deb
./tsm2deb -esabc1 tsm2deb.conf
```
 - then install
  - the all in one package : ..tsm-all
  - all the pakage excep the all in one: …tsm-crypt, …tsm-ssl, …tsm-api, …tsm-ba
 - and  this is it.
 - if you want to thanks me, add me in linkedin and endorse me :)

explanation
-----------
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
 - filepath since it brings only filepath.ko for a special kernel
 - JBB since it is the daemon based on the filepath.ko
 - cit since this looks like a real burden
 - FR since we speak english



Hope it will help.
