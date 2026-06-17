#!/bin/sh

adg_enable=$(nvram get adg_enable)
adg_port=$(nvram get adg_port)
[ -z "$adg_port" ] && adg_port="3000"

start_adg() {
    logger -t "AdGuardHome" "Đang tắt tính năng DNS của Dnsmasq (Giữ lại DHCP)..."
    # Ghi đè port=0 vào file cấu hình dnsmasq hệ thống
    sed -Ei '/port=/d' /etc/storage/dnsmasq/dnsmasq.conf
    echo "port=0" >> /etc/storage/dnsmasq/dnsmasq.conf
    rc dnsmasq restart # Khởi động lại Dnsmasq áp dụng tắt DNS
    sleep 1

    logger -t "AdGuardHome" "Đang khởi động AdGuardHome..."
    mkdir -p /tmp/AdGuardHome
    
    if [ ! -f "/tmp/AdGuardHome/AdGuardHome" ] ; then
        logger -t "AdGuardHome" "Đang tải lõi AdGuardHome mipsle từ GitHub..."
        wget --no-check-certificate -O /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.52/AdGuardHome_linux_mipsle.tar.gz
        if [ $? -eq 0 ]; then
            tar -zxvf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz -C /tmp/
            mv /tmp/AdGuardHome/AdGuardHome /tmp/AdGuardHome/AdGuardHome_bin
            rm -rf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz
        else
            logger -t "AdGuardHome" "LỖI: Không tải được AdGuardHome. Khôi phục lại DNS Dnsmasq..."
            sed -Ei '/port=0/d' /etc/storage/dnsmasq/dnsmasq.conf
            rc dnsmasq restart
            exit 1
        fi
    fi
    
    chmod +x /tmp/AdGuardHome/AdGuardHome_bin
    # Khởi chạy lõi AdGuard Home ở cổng 53
    /tmp/AdGuardHome/AdGuardHome_bin -c /etc/storage/adguardhome.yaml -w /tmp/AdGuardHome >/dev/null 2>&1 &
    logger -t "AdGuardHome" "Khởi động hoàn tất trên cổng quản trị $adg_port."
}

stop_adg() {
    logger -t "AdGuardHome" "Đang dừng AdGuardHome..."
    killall -9 AdGuardHome_bin 2>/dev/null
    rm -rf /tmp/AdGuardHome
    sleep 1
    
    logger -t "AdGuardHome" "Khôi phục lại tính năng DNS mặc định cho Dnsmasq..."
    # Xóa port=0 để Dnsmasq nhận diện lại cổng 53 làm DNS
    sed -Ei '/port=0/d' /etc/storage/dnsmasq/dnsmasq.conf
    rc dnsmasq restart
}

case "$1" in
start)
    if [ "$adg_enable" = "1" ] ; then start_adg; fi
    ;;
stop)
    stop_adg
    ;;
restart)
    stop_adg
    sleep 1
    if [ "$adg_enable" = "1" ] ; then start_adg; fi
    ;;
esac
