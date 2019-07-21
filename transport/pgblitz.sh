#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705 & PhysK
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################

source /opt/pgclone/scripts/cloneclean.sh

# Starting Actions
touch /var/plexguide/logs/pgblitz.log

echo "" >>/var/plexguide/logs/pgblitz.log
echo "" >>/var/plexguide/logs/pgblitz.log
echo "---Starting Blitz: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/plexguide/logs/pgblitz.log
hdpath="$(cat /var/plexguide/server.hd.path)"

startscript() {
    while read p; do

        # Update the vars
        useragent="$(cat /var/plexguide/uagent)"
        bwlimit="$(cat /var/plexguide/blitz.bw)"
        vfs_dcs="$(cat /var/plexguide/vfs_dcs)"

        let "cyclecount++"

        if [[ $cyclecount -gt 4294967295 ]]; then
            cyclecount=0
        fi

        echo "" >>/var/plexguide/logs/pgblitz.log
        echo "---Begin cycle $cyclecount - $p: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/plexguide/logs/pgblitz.log
        echo "Checking for files to upload..." >>/var/plexguide/logs/pgblitz.log

        rsync "$hdpath/downloads/" "$hdpath/move/" \
            -aq --remove-source-files --link-dest="$hdpath/downloads/" \
            --exclude="**_HIDDEN~" --exclude=".unionfs/**" \
            --exclude="**partial~" --exclude=".unionfs-fuse/**" \
            --exclude=".fuse_hidden**" --exclude="**.grab/**" \
            --exclude="**sabnzbd**" --exclude="**nzbget**" \
            --exclude="**qbittorrent**" --exclude="**rutorrent**" \
            --exclude="**deluge**" --exclude="**transmission**" \
            --exclude="**jdownloader**" --exclude="**makemkv**" \
            --exclude="**handbrake**" --exclude="**bazarr**" \
            --exclude="**ignore**" --exclude="**inProgress**"

        if [[ $(find "$hdpath/move" -type f | wc -l) -gt 0 ]]; then
            rclone moveto "$hdpath/move" "${p}{{encryptbit}}:/" \
                --config=/opt/appdata/plexguide/rclone.conf \
                --log-file=/var/plexguide/logs/pgblitz.log \
                --log-level=INFO --stats=5s --stats-file-name-length=0 \
                --max-size=300G \
                --tpslimit=10 \
                --checkers=16 \
                --transfers=8 \
                --no-traverse \
                --fast-list \
                --bwlimit="$bwlimit" \
                --drive-chunk-size="$vfs_dcs" \
                --user-agent="$useragent" \
                --exclude="**_HIDDEN~" --exclude=".unionfs/**" \
                --exclude="**partial~" --exclude=".unionfs-fuse/**" \
                --exclude=".fuse_hidden**" --exclude="**.grab/**" \
                --exclude="**sabnzbd**" --exclude="**nzbget**" \
                --exclude="**qbittorrent**" --exclude="**rutorrent**" \
                --exclude="**deluge**" --exclude="**transmission**" \
                --exclude="**jdownloader**" --exclude="**makemkv**" \
                --exclude="**handbrake**" --exclude="**bazarr**" \
                --exclude="**ignore**" --exclude="**inProgress**"

            echo "Upload has finished." >>/var/plexguide/logs/pgblitz.log
        else
            echo "No files in $hdpath/move to upload." >>/var/plexguide/logs/pgblitz.log
        fi

        echo "---Completed cycle $cyclecount: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/plexguide/logs/pgblitz.log
        echo "$(tail -n 200 /var/plexguide/logs/pgblitz.log)" >/var/plexguide/logs/pgblitz.log
        #sed -i -e "/Duplicate directory found in destination/d" /var/plexguide/logs/pgblitz.log
        sleep 30

        cloneclean

    done </var/plexguide/.blitzfinal
}

# keeps the function in a loop
cheeseballs=0
while [[ "$cheeseballs" == "0" ]]; do startscript; done
