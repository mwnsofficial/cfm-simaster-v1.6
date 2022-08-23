SKIPUNZIP=1

status=""
architecture=""
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/adb/clash"
modules_dir="/data/adb/modules"
bin_path="/system/bin/"
dns_path="/system/etc"
ca_path="${dns_path}/security/cacerts"
clash_data_dir_core="${clash_data_dir}/core"
CPFM_mode_dir="${modules_dir}/clash_premium"
mod_config="${clash_data_dir}/clash.config"
geoip_file_path="${clash_data_dir}/Country.mmdb"

ui_print "- Loading…."
if [ -d "${CPFM_mode_dir}" ] ; then
    touch ${CPFM_mode_dir}/remove && ui_print "- modul CPFM akan dihapus setelah restart."
fi
ui_print "- 0%"
case "${ARCH}" in
    arm)
        architecture="armv7"
        ;;
    arm64)
        architecture="armv8"
        ;;
    x86)
        architecture="386"
        ;;
    x64)
        architecture="amd64"
        ;;
esac
ui_print "- 10%"
mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}
mkdir -p ${clash_data_dir_core}
mkdir -p ${clash_data_dir}/yacd-gh-pages
mkdir -p ${MODPATH}${ca_path}

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2
ui_print "- 30%"
if [ "$(md5sum ${MODPATH}/clash.config | awk '{print $1}')" != "$(md5sum ${mod_config} | awk '{print $1}')" ] ; then
    if [ -f "${mod_config}" ] ; then
        mv -f ${mod_config} ${clash_data_dir}/config.backup
        ui_print "- file konfigurasi telah berubah, dan file konfigurasi asli telah dicadangkan sebagai config.backup."
        ui_print "- disarankan untuk memeriksa file konfigurasi sebelum me-restart telepon."
    fi
    mv ${MODPATH}/clash.config ${clash_data_dir}/
else
    rm -rf ${MODPATH}/clash.config
fi

ui_print "- 50%"

unzip -o ${MODPATH}/yacd-gh-pages.zip -d ${clash_data_dir}/yacd-gh-pages >&2

tar -xjf ${MODPATH}/binary/${ARCH}.tar.bz2 -C ${MODPATH}/system/bin/
mv ${MODPATH}/cacert.pem ${MODPATH}${ca_path}
mv ${MODPATH}/resolv.conf ${MODPATH}${dns_path}
mv ${MODPATH}/clash-dashboard ${clash_data_dir}
mv ${MODPATH}/Country.mmdb ${clash_data_dir}
mv ${MODPATH}/scripts ${clash_data_dir}
mv ${MODPATH}/config.yaml ${clash_data_dir}
mv ${MODPATH}/Command_CFM.prop ${clash_data_dir}
cp ${MODPATH}${bin_path}/clash ${clash_data_dir_core}
rm -rf ${MODPATH}/binary
rm -f ${MODPATH}/yacd-gh-pages.zip
rm -rf ${MODPATH}/yacd-gh-pages

if [ ! -f "${clash_data_dir}/packages.list" ] ; then
    touch ${clash_data_dir}/packages.list
fi
ui_print "- 80%"
sleep 1

set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
set_perm_recursive ${clash_data_dir}/scripts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/yacd-gh-pages ${system_uid} ${system_gid} 0755 0644
set_perm_recursive ${clash_data_dir}/core ${system_uid} ${system_gid} 0755 0755
set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
set_perm  ${MODPATH}/system/bin/ss 0 0 0755
set_perm  ${MODPATH}/system/bin/clash 0 0 6755
set_perm  ${MODPATH}${ca_path}/cacert.pem 0 0 0644
set_perm  ${MODPATH}${dns_path}/resolv.conf 0 0 0755
set_perm  ${clash_data_dir}/scripts/clash.tproxy 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.tool 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.inotify 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.service 0  0  0755
set_perm  ${clash_data_dir}/clash.config ${system_uid} ${system_gid} 0755
set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644
ui_print "- 100%"








