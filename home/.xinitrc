#!/bin/sh

# 1. البيئة الأساسية
export PATH=${PATH}:${HOME}/scripts
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 2. متغيرات الواجهة
export DESKTOP_SESSION=openbox
export XDG_CURRENT_DESKTOP=openbox
export QT_QPA_PLATFORMTHEME=qt5ct

# 3. تشغيل الخدمات الأساسية (قبل الواجهة)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval `dbus-launch --sh-syntax --exit-with-session`
fi

# 4. إعداد اللغة مع تأخير بسيط لتجنب تجمد اللوحة
(sleep 2 && setxkbmap -layout "us,ara" -option "grp:win_space_toggle") &

# 5. تشغيل البرامج (يفضل نقلها للـ autostart، لكن سنبقيها هنا مؤقتاً لطلبك)
# ~/scripts/random_wallpaper.sh &
# ~/scripts/__openbox_restart_tint2.sh &
~/scripts/__openbox_restart_dzen2.sh &

# السطر الأخير
exec openbox-session
