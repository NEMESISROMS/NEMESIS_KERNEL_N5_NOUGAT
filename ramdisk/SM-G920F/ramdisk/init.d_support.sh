#!/system/bin/sh

on property:sys.boot_completed=1
    start sysinit
    start deepsleep
    
service sysinit /sbin/sysinit.sh
    class late_start
    user root
    group root
    seclabel u:r:init:s0
    oneshot
    disabled
  
service deepsleep /sbin/deepsleep.sh
    class late_start
    user root
    group root
    seclabel u:r:init:s0
    oneshot
    disabled
