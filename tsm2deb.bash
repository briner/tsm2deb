#!/bin/bash
#
# all the documentation is on the github:
# https://github.com/briner/tsm2deb
# in the README

if [[ $(uname -m) != 'x86_64' ]] ; then
    echo "this script only works for amd64 distribution"
    exit 1
fi


define_variable()
{   
    # TSM_ROOT defines the path where the rpms are. tsm4ubuntu will work
    # in this directory
    TSM_ROOT=~/packaging/tsm/7.1.0.1

    # the name of the package will be
    # <short_org>-<TSM_NAME>-{ba,api..}_<TSM_VER>-<DDEB_VER>
    # so for the current case: unige-tsm-ba_6.3.0-2.deb
    TSM_NAME=TSM ; # usually it is "TSM"
    TSM_VER=7.1.0.1
    SHORT_ORG=UniGE ; # a short name of your organisation

    # where the tsm files will be installed without the first and the last "/"
    OPT_PATH='usr/lib/tsm' ; # usually it is "opt/tivoli/tsm"

    # email of the packager of these
    EMAIL_MAINTAINER='Cedric BRINER <Cedric.Briner@UniGE.ch>'
    
    #
    # this variable define the name of the rpm for each element 
    # this are the file under ls ${TSM_ROOT} once you untar
    # the file dowloaded 6.4.1.0-TIV-TSMBAC-LinuxX86.tar
    unset drpm
    declare -Ag drpm
    drpm["crypt"]="gskcrypt64-8.0.14.28.linux.x86_64.rpm"
    drpm["ssl"]="gskssl64-8.0.14.28.linux.x86_64.rpm"
    drpm["api"]="TIVsm-API64.x86_64.rpm"
    drpm["ba"]="TIVsm-BA.x86_64.rpm"
    #~ drpm["jbb"]="TIVsm-JBB.x86_64.rpm"

    #
    # this variable define of the version of packaging for each element
    # you should be "0" for your first time.
    unset ddeb_ver
    declare -Ag ddeb_ver
    ddeb_ver["crypt"]="0" 
    ddeb_ver["ssl"]="0"
    ddeb_ver["api"]="0"
    ddeb_ver["ba"]="0"
    #~ ddeb_ver["jbb"]="0"
    ddeb_ver["integration"]="0" ; # this is only used at the University of Geneva
    ddeb_ver["all"]="0" ; # this is only used for the option -1
}

rpm2dir()
{
    define_variable
    for rpm in ${drpm[*]} ; do
        cd ${TSM_ROOT}
	    d=cpio_${rpm%.rpm}
        [ -d $d ] && rm -fr $d
        echo "extracting $rpm in $d" 
        mkdir $d
        cd $d
        rpm2cpio ../${rpm} | cpio -idm
    done
}


#~ ###########################################################
#~ # jbb journal-based-backup
#~ #
#~ wrap_jbb()
#~ {
    #~ OBJ=jbb
#~ 
    #~ # constructed variable
    #~ define_variable
    #~ DEB_VER=${ddeb_ver[${OBJ}]}
    #~ DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    #~ DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}
#~ 
    #~ cd ${TSM_ROOT}
#~ 
    #~ [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    #~ mkdir -p ${DEB_BUILD}/{DEBIAN,${OPT_PATH},usr/bin,etc/init.d}
    #~ mkdir -p ${DEB_BUILD}/{var/log/tsm,var/cache/tsmjbb,etc/tsm}
    #~ rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/opt/tivoli/tsm/ ${DEB_BUILD}/${OPT_PATH}/
    #~ rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/etc ${DEB_BUILD}/${OPT_PATH}/etc
    #~ #
    #~ rsync -aHl --force --delete cpio_${drpm[${OBJ}]%.rpm}/usr/lib64/ ${DEB_BUILD}/${OPT_PATH}/lib/
    #~ # relink to the good position the library
    #~ cd ${DEB_BUILD}/${OPT_PATH}/lib/
    #~ for map in $(ls -l * | \
                 #~ sed "s|[[:blank:]]\{2\}| |g" | \
                 #~ cut -d ' ' -f9- | \
                 #~ sed "s| -> |<==>| ;  s|/../opt/tivoli/tsm/|/|" ) ; do
       #~ target=$(echo $map | sed 's|.*<==>||')
       #~ link_name=$(echo $map | sed 's|<==>.*||')
       #~ ln -sf ${target} ${link_name}
    #~ done
    #~ cd - > /dev/null
    #~ #
    #~ # LINK THE EXECUTABLE TO THE WRAPPER (the wrapper is included in the BA)
    #~ cd ${DEB_BUILD}/usr/bin
    #~ for f in tsmjbbd; do
        #~ ln -sf /${OPT_PATH}/bin/tsm-wrapper ${f}; done
    #~ cd ${TSM_ROOT}
    #~ #
    #~ # config file
    #~ cat > ${DEB_BUILD}/etc/tsm/tsmjbbd.ini << EOF
#~ ; This file is the default one created for ${SHORT_ORG} by ${EMAIL_MAINTAINER}.
#~ ; The sample one provided by IBM is on /${OPT_PATH}/client/ba/bin/tsmjbbd.ini.smp
#~ ; and contain the description for all settings
#~ 
#~ [JournalSettings]
#~ Errorlog=/var/log/tsm/tsmjbb_error.log
#~ Journaldir=/var/cache/tsmjbb
#~ 
#~ 
#~ [JournalExcludeList]
#~ ;   Note that this list contains the journal database files.                  
#~ *.jdb.jbbdb
#~ *.jdbInc.jbbdb
#~ 
#~ 
#~ [JournaledFileSystemSettings]
#~ JournaledFileSystems=/home
#~ 
#~ EOF
    #~ #
    #~ # 
    #~ #
    #~ # DEBIAN control
    #~ cat > ${DEB_BUILD}/DEBIAN/control << EOF
#~ Package: ${DEBNAME}
#~ Version: ${TSM_VER}-${DEB_VER}
#~ Architecture: amd64
#~ Maintainer: ${EMAIL_MAINTAINER}
#~ Section: main
#~ Priority: extra
#~ Description: jbb for ${TSM_NAME} @ ${SHORT_ORG}
    #~ Journal Based Backup for ${TSM_NAME}
    #~ TSM stands for Tivoli Storage Manager and it is a solution for backuping is
    #~ machine at ${SHORT_ORG}.
#~ EOF
    #~ #
    #~ #
    #~ #
    #~ # INIT SCRIPT
    #~ cat > ${DEB_BUILD}/etc/init.d/tsmjbbd << 'EOF'
#~ #!/bin/bash
#~ ### BEGIN INIT INFO
#~ # Provides: tsmjbbd
#~ # Required-Start: $local_fs filepath
#~ # Required-Stop: $local_fs filepath
#~ # Default-Start: 3 5
#~ # Default-Stop: 0 1 2 6
#~ # Short-Description: TSM Journal Based Backup daemon
#~ # Description: Start tsmjbbd to enable Journal Based Backup.
#~ ### END INIT INFO
#~ DAEMON=/usr/bin/tsmjbbd
#~ CONF_FILE=/etc/tsm/tsmjbbd.ini
#~ DIR_LOG=/var/log/tsm
#~ PIDFILE=/var/run/tsmjbbd.pid
#~ 
#~ . /lib/lsb/init-functions
#~ 
#~ start_tsmjbbd()
#~ {
    #~ log_begin_msg "Starting TSM scheduler ..."
    #~ start-stop-daemon -Sqb --startas /usr/bin/tsmjbbd --pidfile ${PIDFILE} --make-pidfile -- -f  /etc/tsm/tsmjbbd.ini || log_end_msg 1
    #~ log_end_msg 0
#~ }
#~ stop_tsmjbbd()
#~ {
    #~ log_begin_msg "Stopping TSM scheduler ..."
    #~ start-stop-daemon -Kqop ${PIDFILE} || log_end_msg 1
    #~ log_end_msg 0
#~ }
#~ 
#~ case "$1" in
  #~ start)
    #~ start_tsmjbbd
    #~ ;;
  #~ stop)
    #~ stop_tsmjbbd
    #~ ;;
  #~ restart)
    #~ stop_tsmjbbd
    #~ start_tsmjbbd
    #~ ;;
  #~ *)
    #~ log_success_msg "Usage: /etc/init.d/tsm {start|stop|restart}"
    #~ exit 1
#~ esac
#~ 
#~ exit 0
#~ EOF
    #~ #
    #~ chmod a+x  ${DEB_BUILD}/etc/init.d/tsmjbbd
    #~ #
    #~ #
    #~ # construct the package
    #~ fakeroot dpkg -b ${DEB_BUILD}
#~ }


###########################################################
# gskcrypt64
#
wrap_crypt()
{
    OBJ=crypt

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}

    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/{DEBIAN,${OPT_PATH}/gsk8_64}
    rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/usr/local/ibm/gsk8_64/ ${DEB_BUILD}/${OPT_PATH}/gsk8_64/
    #
    #
    # DEBIAN control
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: gskcrypt64 for ${TSM_NAME} @ ${SHORT_ORG}
    Crypto Library for ${TSM_NAME}
    TSM stands for Tivoli Storage Manager and it is a solution for backuping is
    machine at ${SHORT_ORG}.
EOF
    #
    #
    # construct the package
    fakeroot dpkg -b ${DEB_BUILD}
}



###########################################################
# gskssl64
#
wrap_ssl()
{
    OBJ=ssl

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}

    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/{DEBIAN,${OPT_PATH}/gsk8_64}
    rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/usr/local/ibm/gsk8_64/ ${DEB_BUILD}/${OPT_PATH}/gsk8_64/
    #
    #
    # DEBIAN control
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: gskssl64 for ${TSM_NAME} @ ${SHORT_ORG}
 SSL Library for ${TSM_NAME}
 TSM stands for Tivoli Storage Manager and it is a solution for backuping is
 machine at ${SHORT_ORG}.
EOF
    #
    #
    # construct the package
    fakeroot dpkg -b ${DEB_BUILD}
}



###########################################################
# API
#
wrap_api()
{
    OBJ=api

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}

    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/{DEBIAN,${OPT_PATH}/client}
    rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/opt/tivoli/tsm/client/ ${DEB_BUILD}/${OPT_PATH}/client/
    #
    rsync -aHl --force --delete cpio_${drpm[${OBJ}]%.rpm}/usr/lib64/ ${DEB_BUILD}/${OPT_PATH}/lib/
    cd ${DEB_BUILD}/${OPT_PATH}/lib/
    # relink to the good position the library
    for map in $(ls -l * | \
                 sed "s|[[:blank:]]\{2\}| |g" | \
                 cut -d ' ' -f9- | \
                 sed "s| -> |<==>| ;  s|/../opt/tivoli/tsm/|/|" ) ; do
       target=$(echo $map | sed 's|.*<==>||')
       link_name=$(echo $map | sed 's|<==>.*||')
       ln -sf ${target} ${link_name}
    done
    cd - > /dev/null
    #
    #
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: api for ${TSM_NAME} @ ${SHORT_ORG}
 API Library for ${TSM_NAME}
 TSM stands for Tivoli Storage Manager and it is a solution for backuping is
 machine at ${SHORT_ORG}.
EOF
    #
    #
    # construct the package
    fakeroot dpkg -b ${DEB_BUILD}
}



###########################################################
# BA
#
wrap_ba()
{
    OBJ=ba

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}

    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/{DEBIAN,usr/bin,var/log/tsm,${OPT_PATH}/bin}
    mkdir -p ${DEB_BUILD}/{etc/tsm,etc/init.d}
    mkdir -p ${DEB_BUILD}/{usr/share/pixmaps,usr/share/applications}
    mkdir -p ${DEB_BUILD}/usr/share/doc/${DEBNAME}
    rsync -aHl cpio_${drpm[${OBJ}]%.rpm}/opt/tivoli/tsm/ ${DEB_BUILD}/${OPT_PATH}/
    #
    #
    # to remove the error:
    # ANS0102W Unable to open the message repository
    #   /opt/uau/tsm/client/ba/bin//EN_US/dsmclientV3.cat.
    #   The American English repository will be used instead.
    cd ${DEB_BUILD}/${OPT_PATH}/client/ba/bin
    ln -s ../../lang/EN_US
    cd ${TSM_ROOT}
    #
    #
    # push the dsm.opt and dsm.sys in /etc/tsm with a soft link
    mv ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/dsm.sys.smp ${DEB_BUILD}/etc/tsm
    mv ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/dsm.opt.smp ${DEB_BUILD}/etc/tsm
    ln -s /etc/tsm/dsm.opt ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/dsm.opt
    ln -s /etc/tsm/dsm.sys ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/dsm.sys
    cat > ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/README_${SHORT_ORG^^} << EOF
the dsm.opt and dsm.sys must reside in /${OPT_PATH}/bin as it is in the rpm delivered by IBM,
for convenience we push them in /etc/tsm and add a link to it in /${OPT_PATH}/client/ba/bin
so that the configuration appear
EOF
    cp ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/README_${SHORT_ORG^^} ${DEB_BUILD}/etc/tsm/README_${SHORT_ORG^^}
    #
    #
    # WRAPPER to easy the install of bin on /usr/bin and to
    # let the agent to use this environment when passinf from user to root
    cat > ${DEB_BUILD}/${OPT_PATH}/bin/tsm-wrapper << EOF
#!/bin/bash
# dsmj can use openjdk wahou # to force the use of Sun's Java
# dsmj can use openjdk wahou # export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
export DSM_DIR=/${OPT_PATH}/client/ba/bin/
export LANG=en_US
export LC_TYPE=en_US
export LD_LIBRARY_PATH="/${OPT_PATH}/client/api/bin64:\
/${OPT_PATH}/gsk8/lib/:\
/${OPT_PATH}/lib/"

appname=\$(basename \$0)
exec \${DSM_DIR}/\${appname} \$@
EOF
    chmod a+x ${DEB_BUILD}/${OPT_PATH}/bin/tsm-wrapper
    #
    #
    # LDCONFIG
    mkdir -p ${DEB_BUILD}/etc/ld.so.conf.d
    cat > ${DEB_BUILD}/etc/ld.so.conf.d/${SHORT_ORG,,}-${TSM_NAME,,}.conf << EOF
/${OPT_PATH}/client/api/bin64
/${OPT_PATH}/gsk8_64/lib64
/${OPT_PATH}/lib
EOF
    #
    #
    # LINK THE EXECUTABLE TO THE WRAPPER
    cd ${DEB_BUILD}/usr/bin
    for f in dsmadmc  dsmagent  dsmc  dsmcad  dsmj  dsmswitch  dsmtca  dsmtrace ; do
        ln -sf /${OPT_PATH}/bin/tsm-wrapper ${f}; done
    cd ${TSM_ROOT}
    #
    #
    # INIT SCRIPT
    cat > ${DEB_BUILD}/etc/init.d/tsm << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          tsm
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by tsm.
### END INIT INFO

DAEMON=/usr/bin/dsmc
DSM_LOG=/var/log/tsm
PIDFILE=/var/run/tsm.pid

. /lib/lsb/init-functions

start_tsm()
{
    log_begin_msg "Starting TSM scheduler ..."
    mkdir -p ${DSM_LOG}
    start-stop-daemon -Sqb --startas /usr/bin/dsmc --pidfile ${PIDFILE} --make-pidfile --chdir ${DSM_LOG} -- schedule || log_end_msg 1
    log_end_msg 0
}
stop_tsm()
{
    log_begin_msg "Stopping TSM scheduler ..."
    start-stop-daemon -Kqop ${PIDFILE} || log_end_msg 1
    log_end_msg 0
}

case "$1" in
  start)
    start_tsm
    ;;
  stop)
    stop_tsm
    ;;
  restart)
    stop_tsm
    start_tsm
    ;;
  *)
    log_success_msg "Usage: /etc/init.d/tsm {start|stop}"
    exit 1
esac

exit 0
EOF
    #
    chmod a+x  ${DEB_BUILD}/etc/init.d/tsm
    #
    #
    # rudimentary doc for unige-ba
    cat > ${DEB_BUILD}/usr/share/doc/${DEBNAME}/README << EOF
- configure dsm.sys and dsm.opt
- inform the tsm manager about your config
- test your config with "dsmc i" until it works
- update-rc.d tsm
- /etc/init.d/tsm start
EOF
    #
    #
    # DEBIAN control
    PREFIX=${SHORT_ORG,,}-${TSM_NAME,,}
    DEPENDS="${PREFIX}-crypt, ${PREFIX}-ssl, ${PREFIX}-api, default-jre"
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Depends: ${DEPENDS}
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: ba for ${TSM_NAME} @ ${SHORT_ORG}
 Backup Agent for ${TSM_NAME}
 TSM stands for Tivoli Storage Manager and it is a solution for backuping is
 machine at ${SHORT_ORG}.
EOF
    #
    #
    # DEBIAN postinst
    cat > ${DEB_BUILD}/DEBIAN/postinst << 'EOF'
#!/bin/sh
set -e

if [ "$1" = "configure" ]; then
	ldconfig
    #
    # check if there is a valid configuration
    if LC_ALL=C dsmc query session > /dev/null 2>&1 ; then
        if LC_ALL=C dsmc query schedule 2>&1 | grep "There are no schedules associated with this node" > /dev/null ; then
            echo " - tsm configuration is good and planning is disabled"
            echo " - if you need a planning, configure it and then"
            echo "   - update-rc.d tsm defaults"
            echo "   - invoke-rc.d tsm start"
            invoke-rc.d tsm stop > /dev/null
            update-rc.d -f tsm remove >/dev/null
        else
            echo " - tsm configuration is good and planning is enabled"
            echo " - enabling the tsm daemon"
    	    update-rc.d tsm defaults >/dev/null
            invoke-rc.d tsm start || exit $?
        fi
    else
        echo " - tsm is not configured or the configuration is broken"
        echo " - we will not launch the daemon tsm"
        echo " - when tsm will be well configured and the schedule planned, do:"
        echo "   - update-rc.d tsm defaults"
        echo "   - invoke-rc.d tsm start"
        invoke-rc.d tsm stop > /dev/null
        update-rc.d -f tsm remove >/dev/null
    fi
fi
EOF
    #
    chmod a+x ${DEB_BUILD}/DEBIAN/postinst
    #
    #
    # DEBIAN postrm
    cat > ${DEB_BUILD}/DEBIAN/postrm << EOF
#!/bin/sh
set -e

if [ "$1" = "remove" ]; then
	ldconfig
    invoke-rc.d tsm stop > /dev/null
	update-rc.d tsm remove >/dev/null
fi

EOF
    #
    chmod a+x ${DEB_BUILD}/DEBIAN/postrm
    #
    #
    # DESKTOP dsmj & dsmc
    unzip -p cpio_${drpm[${OBJ}]%.rpm}/opt/tivoli/tsm/client/ba/bin/dsm.jar \
             COM/ibm/storage/adsm/cadmin/clientgui/images/dsmwin32.gif \
         | convert - ${DEB_BUILD}/usr/share/pixmaps/dsmwin32.png
    cat > ${DEB_BUILD}/usr/share/applications/dsmj.desktop  << EOF
[Desktop Entry]
Name=dsmj
Comment=This is a backup solution @ UniGE
Exec=tsm
Icon=dsmwin32.png
Terminal=false
Type=Application
Categories=System;
EOF
    cat > ${DEB_BUILD}/usr/share/applications/dsmc.desktop  << EOF
[Desktop Entry]
Name=dsmc
Comment=This is a backup solution @ UniGE
Exec=dsmc
Icon=dsmwin32.png
Terminal=true
Type=Application
Categories=System;
EOF
    #
    #
    # construct package
    fakeroot dpkg -b ${DEB_BUILD}
}



###########################################################
# INTEGRATION
wrap_integration()
{
    OBJ=integration

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}


    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/{usr/share/pixmaps,usr/share/applications}
    mkdir -p ${DEB_BUILD}/{etc/tsm,usr/bin,DEBIAN,${OPT_PATH}/bin}

    #
    #
    # GUI NOTIFICATION start
    cat > ${DEB_BUILD}/${OPT_PATH}/bin/notify-send-tsm.start  << EOF
#!/bin/bash
# 60000 ms= 1min
?notify-send -i /usr/share/pixmaps/ubuntu-at-unige.png --expire-time=60000 "Sauvegarde Start" \\
  "Lancement de la sauvegarde de votre machine par TSM sur les serveurs de l'UniGE."
EOF
    #
    chmod a+x ${DEB_BUILD}/${OPT_PATH}/bin/notify-send-tsm.start
    #
    #
    # GUI NOTIFICATION stop
    cat > ${DEB_BUILD}/${OPT_PATH}/bin/notify-send-tsm.stop  << EOF
#!/bin/bash
# 1800000 ms= 30min
notify-send -i /usr/share/pixmaps/ubuntu-at-unige.png  --expire-time=1800000 "Sauvegarde Stop" \\
  "La sauvegarde de votre machines par TSM sur les seveurs de l'UniGE a abouti."
EOF
    #
    chmod a+x ${DEB_BUILD}/${OPT_PATH}/bin/notify-send-tsm.stop
    #
    #
    # TSM CONFIGURE TOOL WRITTEN BY J.-M. NAEF
    cat > ${DEB_BUILD}/usr/bin/tsm-configure << EOF
#!/bin/bash
exec javaws "http://sos.unige.ch/eztsm/apps/servlet/jws?ezubuntu"
EOF
    #
    chmod a+x ${DEB_BUILD}/usr/bin/tsm-configure
    #
    #
    # FIRST SHOOT TSM LAUNCH
    
    cat > ${DEB_BUILD}/usr/bin/tsm << 'EOF'
#!/bin/bash
#
#
[ -f ${OPT_PATH}/tsm/client/ba/bin/dsm.sys -a -f ${OPT_PATH}/tsm/client/ba/dsm.opt ] && exec dsmj
#
#
echo $LANG | grep -q fr
if [ $? -eq 0 ]
then
    title="Configurer TSM ?"
    text="TSM n'est pas configurer. Nous vous suggérons de lancer \"TSM configure\".\
\n\t- Clic \"Oui\" pour configurer TSM (recommandé).\
\n\t- Clic \"Non\" pour lancer l'application TSM."
else
    title="Configure TSM ?"
    text="TSM is not yet configured. We suggest you to configure it with the \"TSM configuration\".\
\n\t- Clic \"Yes\" to configure it (recommended).\
\n\t- Clic \"No\" to launch the TSM application."
fi
zenity --title="$title" --question --text="$text"
#
#
if [ $? -eq 0 ]
then
   exec tsm-configure
else
   exec dsmj
fi
EOF
    #
    chmod a+x  ${DEB_BUILD}/usr/bin/tsm
    #
    #
    # create not configured dsm.sys and dsm.opt on ../tsm/client/ba/bin
    #
    #
    # DSM.SYS
    cat  > ${DEB_BUILD}/etc/tsm/dsm.sys.example@${SHORT_ORG,,} << EOF
* - copy this file under ${DEB_BUILD}/${OPT_PATH}/client/ba/bin/dsm.sys
* - uncomment the lines of the file dsm.sys
*   under "* ----------------" by removing the "*"
* - modify the value <change_this...> at NODENAME
* - send to your tsm administrator the line uncommented
* - wait for his response and change accordingly your dsm.sys
* - test your config by invoking "dsmc i"
* - if it works, then you might be interested to activate the daemon with
*   - update-rc.d tsm
*   - /etc/init.d/tsm start
* ----------------
*SErvername thismachine
* COMMMethod        TCPip
* TCPPort           1507
* TCPServeraddress  sos7.unige.ch
* NODENAME          <change_this_field_with_the_nodename_give_It_is_usually_the_hostname>
* PASSWORDACCESS    generate
* SCHEDLOGRetention 7 D
* PRENSChedulecmd   ${OPT_PATH}/tsm/bin/notify-send-tsm.start
* POSTNSChedulecmd  ${OPT_PATH}/tsm/bin/notify-send-tsm.stop
EOF
    #
    #
    # DSM.OPT
    cat  > ${DEB_BUILD}/etc/tsm/dsm.opt.example@${SHORT_ORG,,} << EOF
*SErvername thismachine
*DOMAIN     ALL-LOCAL
EOF
    cd ${TSM_ROOT}
    #
    #
    # DESKTOP tsm-configure
    wget -q -O ${DEB_BUILD}/usr/share/pixmaps/tsm-configure.png http://ubuntu.unige.ch/img/icon/tsm-configure.png
    cat > ${DEB_BUILD}/usr/share/applications/tsm-configure.desktop << EOF
[Desktop Entry]
Name=tsm-configure
Comment=Configure TSM the UniGE way
Comment[fr]=Configurer TSM à la sauce UniGE
Exec=tsm-configure
Icon=tsm-configure.png
Terminal=false
Type=Application
Categories=System;ubuntu-at-unige;
EOF
    #
    #
    # DESKTOP tsm
    wget -q -O ${DEB_BUILD}/usr/share/pixmaps/tsm.png http://ubuntu.unige.ch/img/icon/tsm.png
    cat > ${DEB_BUILD}/usr/share/applications/tsm.desktop  << EOF
[Desktop Entry]
Name=tsm
Comment=This is a backup solution @ ${SHORT_ORG}
Exec=tsm
Icon=tsm.png
Terminal=false
Type=Application
Categories=System;ubuntu-at-unige;
EOF
    #
    #
    # DEBIAN control
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Depends: libnotify-bin, ubuntu-at-unige, zenity, ${SHORT_ORG,,}-${TSM_NAME,,}-ba
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: integration for TSM @ ${SHORT_ORG}
 Integration for TSM
 TSM stands for Tivoli Storage Manager and it is a solution for backuping is
 machine at ${SHORT_ORG}.
EOF
    #
    #
    # construct the package
    fakeroot dpkg -b ${DEB_BUILD}
}



###########################################################
# ALL IN ONE
#
all_in_one()
{
    define_variable
    OBJ=all

    # constructed variable
    define_variable
    DEB_VER=${ddeb_ver[${OBJ}]}
    DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${OBJ}
    DEB_BUILD=${TSM_ROOT}/${DEBNAME}_${TSM_VER}-${DEB_VER}
    #
    #
    cd ${TSM_ROOT}

    [ -d ${DEB_BUILD} ] && rm -fr ${DEB_BUILD}
    mkdir -p ${DEB_BUILD}/DEBIAN
    #
    #
    if test "${IS_WRAP_UNIGE}" = "True"
    then
        DEB_TO_INCLUDE="$(echo ${!ddeb_ver[@]} | sed 's|all||')"
    else
        DEB_TO_INCLUDE="$(echo ${!ddeb_ver[@]} | sed 's|all||' | sed 's|integration||')"
    fi

    #
    # 
    echo "rsync data of on ${OBJ}"
    for SUB_OBJ in ${DEB_TO_INCLUDE}
    do
        echo "- ${SUB_OBJ}"
        SUB_DEB_VER=${ddeb_ver[${SUB_OBJ}]}
        SUB_DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${SUB_OBJ}
        SUB_DEB_BUILD=${TSM_ROOT}/${SUB_DEBNAME}_${TSM_VER}-${SUB_DEB_VER}
        #
        # rsync
        echo -n "  - data… "
        cmd="rsync -aHl --exclude=DEBIAN ${SUB_DEB_BUILD}/ ${DEB_BUILD}/"
        if eval $cmd &> /dev/null
        then
            echo "✔"
        else
            echo "✘"
        fi
        #
        # postinst & postrm
        echo -n "  - postinst… "
        if test -f ${SUB_DEB_BUILD}/DEBIAN/postinst
        then
            echo "✔"
            echo "" >> ${DEB_BUILD}/DEBIAN/postinst
            echo "###############" >> ${DEB_BUILD}/DEBIAN/postinst
            echo "# ${SUB_OBJ}"    >> ${DEB_BUILD}/DEBIAN/postinst
            echo "###############" >> ${DEB_BUILD}/DEBIAN/postinst
            sed -n '2,$p' ${SUB_DEB_BUILD}/DEBIAN/postinst >> ${DEB_BUILD}/DEBIAN/postinst
        else
            echo "✘"        
        fi
        echo -n "  - postrm… "
        if test -f ${SUB_DEB_BUILD}/DEBIAN/postrm
        then
            echo "✔"
            echo "" >> ${DEB_BUILD}/DEBIAN/postrm
            echo "###############" >> ${DEB_BUILD}/DEBIAN/postrm
            echo "# ${SUB_OBJ}"    >> ${DEB_BUILD}/DEBIAN/postrm
            echo "###############" >> ${DEB_BUILD}/DEBIAN/postrm
            sed -n '2,$p' ${SUB_DEB_BUILD}/DEBIAN/postrm >> ${DEB_BUILD}/DEBIAN/postrm
        else
            echo "✘"
        fi
    done | sed -u "s|^|  |"
    if test -f ${DEB_BUILD}/DEBIAN/postrm
    then
        sed -i '1i#!/bin/bash' ${DEB_BUILD}/DEBIAN/postrm
        chmod a+x ${DEB_BUILD}/DEBIAN/postrm
    fi
    if test -f ${DEB_BUILD}/DEBIAN/postrm
    then
        sed -i '1i#!/bin/bash' ${DEB_BUILD}/DEBIAN/postinst
        chmod a+x ${DEB_BUILD}/DEBIAN/postinst
    fi
    #
    # control
    DEPENDS=$(for SUB_OBJ in ${DEB_TO_INCLUDE}
            do
                SUB_DEB_VER=${ddeb_ver[${SUB_OBJ}]}
                SUB_DEBNAME=${SHORT_ORG,,}-${TSM_NAME,,}-${SUB_OBJ}
                SUB_DEB_BUILD=${TSM_ROOT}/${SUB_DEBNAME}_${TSM_VER}-${SUB_DEB_VER}
                grep -E "^Depends:" ${SUB_DEB_BUILD}/DEBIAN/control | sed "s|Depends:||"
            done | tr -s " " "\n"  | sed "s|,||" | grep -v "${SHORT_ORG,,}-tsm-" \
                 | sort -u | sed '/^\s*$/d' | tr -s "\n" " " )
    ADEPENDS=($DEPENDS)
    SAVE_IFS=$IFS
    IFS=","
    DEPENDSJOIN="${ADEPENDS[*]}"
    IFS=$SAVE_IFS
    DEBIAN_DEPENDS=$(echo $DEPENDSJOIN | sed -s "s|,|, |")
    cat > ${DEB_BUILD}/DEBIAN/control << EOF
Package: ${DEBNAME}
Version: ${TSM_VER}-${DEB_VER}
Architecture: amd64
Depends: ${DEBIAN_DEPENDS}
Maintainer: ${EMAIL_MAINTAINER}
Section: main
Priority: extra
Description: all in one for TSM @ ${SHORT_ORG}
 This includes all the package in one (ssl, crypt, ba, api, jbb...)
EOF
    #
    #
    # construct the package
    fakeroot dpkg -b ${DEB_BUILD}
}


###########################################################
# last output
#
last_output()
{
define_variable
echo "do fo eg: sudo dpkg  -i ${TSM_ROOT}/*deb"
}

###########################################################
# main
#

usage () {
	scriptname=$(basename ${0})
   cat <<EOF
Usage: $scriptname -esabc1
       usually we do:
         - to do a package per rpm
           $scriptname -esabc
         - to do a package where everything is into one
           $scriptname -esabc1
         - to do a package per rpm @ UNIGE
           $scriptname -esabcu
         - to do a package where everything is into one @ UNIGE
           $scriptname -esabcu1
   -h   displays basic help
   -v   verbose
   -l   stdout and stderr to \$LOG_PATH(${LOG_PATH})
   -e   extract the RPMs in directories
   -s   wrapp ssl
   -a   wrapp api
   -b   wrapp ba
   -c   wrapp crypt
   -1   wrapp then all in one
   -u   wrap unige
EOF
   exit 0
}

IS_EXTRACT="False"
IS_WRAP_SSL="False"
IS_WRAP_API="False"
IS_WRAP_BA="False"
IS_WRAP_CRYPT="False"
IS_WRAP_SSL="False"
IS_WRAP_UNIGE="False"
IS_WRAP_SOMETHING="False"
IS_WRAP_ALL_IN_ONE="False"
while getopts ":esabcuh1" opt; do
  case $opt in
    e)
      IS_EXTRACT="True"
      ;;
    s)
      IS_WRAP_SSL="True"
      IS_WRAP_SOMETHING="True"
      ;;
    a)
      IS_WRAP_API="True"
      IS_WRAP_SOMETHING="True"
      ;;
    b)
      IS_WRAP_BA="True"
      IS_WRAP_SOMETHING="True"
      ;;
    c)
      IS_WRAP_CRYPT="True"
      IS_WRAP_SOMETHING="True"
      ;;
    s)
      IS_WRAP_SSL="True"
      IS_WRAP_SOMETHING="True"
      ;;
    u)
      IS_WRAP_UNIGE="True"
      IS_WRAP_SOMETHING="True"
      ;;
    1)
      IS_WRAP_SOMETHING="True"
      IS_WRAP_ALL_IN_ONE="True"
      ;;
    h)
      usage
      ;;
  esac
done


shift $((OPTIND-1))

if test "${IS_EXTRACT}" = "True"
then
    echo "extract RPMs 2 directory with cpio"
    echo "----------------------------------"
    cd ${TSM_ROOT}
    rpm2dir | sed -u "s|^|  |"
fi

if test "${IS_WRAP_SOMETHING}" = "True"
then
    echo
    echo "wrapping"
    echo "--------"
fi

if test "${IS_WRAP_SSL}" = "True"
then
    echo
    echo " - wrap ssl"
    echo "   --------"
    wrap_ssl | sed -u "s|^|     |"
fi

if test "${IS_WRAP_CRYPT}" = "True"
then
    echo
    echo " - wrap_crypt"
    echo "   ----------"
    wrap_crypt | sed -u "s|^|     |"
fi

if test "${IS_WRAP_API}" = "True"
then
    echo
    echo " - wrap api"
    echo "   --------"
    wrap_api | sed -u "s|^|     |"
fi

if test "${IS_WRAP_BA}" = "True"
then
    echo
    echo " - wrap ba"
    echo "   -------"
    wrap_ba | sed -u "s|^|     |"
fi

#~ if test "${IS_WRAP_JBB}" = "True"
#~ then
    #~ echo
    #~ echo " - wrap jbb"
    #~ echo "   --------"
    #~ wrap_jbb | sed -u "s|^|     |"
#~ fi

if test "${IS_WRAP_UNIGE}" = "True"
then
    echo
    echo " - unige integration"
    echo "   -----------------"
    wrap_integration | sed -u "s|^|     |"
fi

if test "${IS_WRAP_ALL_IN_ONE}" = "True"
then
    echo
    echo " - all in one"
    echo "   ----------"
    all_in_one | sed -u "s|^|     |"
  
fi


echo
echo "check the new package created"
echo "-----------------------------"
last_output | sed -u "s|^|  |"


