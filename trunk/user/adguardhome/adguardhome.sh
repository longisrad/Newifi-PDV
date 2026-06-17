#!/bin/sh

adg_enable=$(nvram get adg_enable)
adg_port=$(nvram get adg_port)
[ -z "$adg_port" ] && adg_port="3000"

start_adg() {
    logger -t "AdGuardHome" "Đang nhường cổng 53 của Dnsmasq..."
    nvram set dhcp_dns_port=53535 # Đẩy Dnsmasq sang cổng khác
    rc dnsmasq restart            # Khởi động lại Dnsmasq áp dụng cổng mới
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
            logger -t "AdGuardHome" "LỖI: Không thể tải AdGuardHome. Khôi phục Dnsmasq..."
            nvram set dhcp_dns_port=53
            rc dnsmasq restart
            exit 1
        fi
    fi
    
    chmod +x /tmp/AdGuardHome/AdGuardHome_bin
    # Khởi chạy lõi AdGuard Home ở cổng 53
    /tmp/AdGuardHome/AdGuardHome_bin -c /etc/storage/adguardhome.yaml -w /tmp/AdGuardHome >/dev/null 2>&1 &
    logger -t "AdGuardHome" "Khởi động thành công trên cổng quản trị $adg_port."
}

stop_adg() {
    logger -t "AdGuardHome" "Đang dừng AdGuardHome..."
    killall -9 AdGuardHome_bin 2>/dev/null
    rm -rf /tmp/AdGuardHome
    sleep 1
    
    logger -t "AdGuardHome" "Khôi phục cổng 53 cho Dnsmasq..."
    nvram set dhcp_dns_port=53
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
