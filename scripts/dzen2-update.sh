#!/bin/sh

# ------------------------------
# DZEN2 UPDATE - FINAL DESKTOP VERSION
# ------------------------------

# الإعدادات اللونية (نفس ذوق Vermaden)
CLA='^fg(#aaaaaa)'
CVA='^fg(#eeeeee)'
CDE='^fg(#dd0000)'

# وظيفة حسابية مخصصة للكسور
__math() {
  local SCALE=1
  local RESULT=$( echo "scale=${SCALE}; ${@}" | bc -l )
  if echo ${RESULT} | grep --color -q '^\.'
  then
    echo -n 0
  fi
  echo ${RESULT}
  unset SCALE
  unset RESULT
}

# --- جمع البيانات ---

# 1. التاريخ والوقت
DATE=$( date +%Y/%m/%d/%a/%H:%M )

# 2. سرعة المعالج والحرارة
FREQ=$( sysctl -n dev.cpu.0.freq )
# محاولة جلب الحرارة من المعالج مباشرة (تعمل بعد تحميل coretemp أو amdtemp)
TEMP=$( sysctl -n dev.cpu.0.temperature 2>/dev/null || echo "N/A" )

# 3. استهلاك الذاكرة (RAM) بالجيجابايت
MEM_FREE=$(( $(sysctl -n vm.stats.vm.v_free_count) + $(sysctl -n vm.stats.vm.v_inactive_count) + $(sysctl -n vm.stats.vm.v_cache_count) ))
MEM_TOTAL=$(sysctl -n vm.stats.vm.v_page_count)
MEM_USED_P=$(( MEM_TOTAL - MEM_FREE ))
MEM=$( __math ${MEM_USED_P} \* 4096 / 1024 / 1024 / 1024 )

# 4. الشبكة (تعتمد على السكربتات الأخرى الملحقة)
IF_IP=$(   ~/scripts/__conky_if_ip.sh )
IF_GW=$(   ~/scripts/__conky_if_gw.sh )
IF_DNS=$(  ~/scripts/__conky_if_dns.sh )
IF_PING=$( ~/scripts/__conky_if_ping.sh dzen2 )

# 5. الصوت (إصلاح شامل ليعمل مع Mixer الحديث)
# نقوم بجلب القيمة وتنظيف المسافات
VOL=$( mixer vol | awk -F ':' '{print $2}' | tr -d ' ' )
PCM=$( mixer pcm | awk -F ':' '{print $2}' | tr -d ' ' )

# 6. مساحة القرص (نظام UFS)
FS=$( df -h / | awk 'NR==2 {printf("root/%s ",$4)}' )

# 7. البرامج الأكثر استهلاكاً (Top Processes)
PS=$( ps ax -o %cpu,rss,comm | sed 1d | grep -v 'idle$' | sort -r -n \
     | head -3 | awk '{printf("%s/%d%%/%.1fGB ",$3,$1,$2/1024/1024)}' )

# --- عرض البيانات على الشريط ---

echo -n        " ${CLA}date: ${CVA}${DATE} "
echo -n "${CDE}| ${CLA}sys: ${CVA}${FREQ}MHz/${TEMP}/${MEM}GB "
echo -n "${CDE}| ${CLA}ip: ${CVA}${IF_IP}"
echo -n " ${CDE}| ${CLA}gw: ${CVA}${IF_GW} "
echo -n "${CDE}| ${CLA}dns: ${CVA}${IF_DNS} "
echo -n "${CDE}| ${CLA}ping: ${CVA}${IF_PING} "
echo -n "${CDE}| ${CLA}vol/pcm: ${CVA}${VOL}/${PCM} "
echo -n "${CDE}| ${CLA}fs: ${CVA}${FS}"
echo -n "${CDE}| ${CLA}top: ${CVA}${PS}"
echo

# تسجيل الإحصائيات (اختياري)
mkdir -p ~/scripts/stats
echo '1' >> ~/scripts/stats/$( basename ${0} )