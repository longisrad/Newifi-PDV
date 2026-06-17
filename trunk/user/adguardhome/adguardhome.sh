#!/bin/sh

adg_enable=$(nvram get adg_enable)
adg_port=$(nvram get adg_port)
[ -z "$adg_port" ] && adg_port="3000"

start_adg() {
    logger -t "AdGuardHome" "Đang khởi động AdGuardHome..."
    mkdir -p /tmp/AdGuardHome
    
    # Nếu file thực thi chưa có sẵn trong RAM, tiến hành tải bản mipsle từ Github
    if [ ! -f "/tmp/AdGuardHome/AdGuardHome" ] ; then
        logger -t "AdGuardHome" "Không tìm thấy file chạy. Đang tải bản mipsle từ GitHub..."
        wget --no-check-certificate -O /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.52/AdGuardHome_linux_mipsle.tar.gz
        
        if [ $? -eq 0 ]; then
            tar -zxvf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz -C /tmp/
            mv /tmp/AdGuardHome/AdGuardHome /tmp/AdGuardHome/AdGuardHome_bin
            rm -rf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz
        else
            logger -t "AdGuardHome" "LỖI: Không thể tải AdGuardHome. Vui lòng kiểm tra kết nối mạng của Router!"
            exit 1
        fi
    fi
    
    chmod +x /tmp/AdGuardHome/AdGuardHome_bin
    
    # Chạy AdGuardHome dạng daemon ngầm, lưu cấu hình tại /etc/storage
    /tmp/AdGuardHome/AdGuardHome_bin -c /etc/storage/adguardhome.yaml -w /tmp/AdGuardHome >/dev/null 2>&1 &
    
    logger -t "AdGuardHome" "Khởi động thành công trên cổng $adg_port."
}

stop_adg() {
    logger -t "AdGuardHome" "Đang dừng AdGuardHome..."
    killall -9 AdGuardHome_bin 2>/dev/null
    rm -rf /tmp/AdGuardHome
}

case "$1" in
start)
    if [ "$adg_enable" = "1" ] ; then
        start_adg
    fi
    ;;
stop)
    stop_adg
    ;;
restart)
    stop_adg
    sleep 2
    if [ "$adg_enable" = "1" ] ; then
        start_adg
    fi
    ;;
*)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac
