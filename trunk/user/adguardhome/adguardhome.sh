#!/bin/sh

adg_enable=$(nvram get adg_enable)
adg_port=$(nvram get adg_port)
[ -z "$adg_port" ] && adg_port="3000"

start_adg() {
    logger -t "AdGuardHome" "Đang tắt tính năng DNS của Dnsmasq (Giữ lại DHCP)..."
    sed -Ei '/port=/d' /etc/storage/dnsmasq/dnsmasq.conf
    echo "port=0" >> /etc/storage/dnsmasq/dnsmasq.conf
    restart_dhcpd
    sleep 1

    logger -t "AdGuardHome" "Đang khởi động AdGuardHome..."
    mkdir -p /tmp/AdGuardHome
    
    # SỬA LỖI LOGIC: Kiểm tra file _bin cuối cùng để tránh bị tải lặp vô hạn
    if [ ! -f "/tmp/AdGuardHome/AdGuardHome_bin" ] ; then
        logger -t "AdGuardHome" "Đang tải lõi AdGuardHome mipsle từ GitHub..."
        wget --no-check-certificate -O /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.52/AdGuardHome_linux_mipsle.tar.gz
        if [ $? -eq 0 ]; then
            tar -zxvf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz -C /tmp/
            mv /tmp/AdGuardHome/AdGuardHome /tmp/AdGuardHome/AdGuardHome_bin
            rm -rf /tmp/AdGuardHome/AdGuardHome_linux_mipsle.tar.gz
        else
            logger -t "AdGuardHome" "LỖI: Không tải được AdGuardHome. Khôi phục lại DNS Dnsmasq..."
            sed -Ei '/port=0/d' /etc/storage/dnsmasq/dnsmasq.conf
            restart_dhcpd
            exit 1
        fi
    fi
    
    chmod +x /tmp/AdGuardHome/AdGuardHome_bin
    /tmp/AdGuardHome/AdGuardHome_bin -c /etc/storage/adguardhome.yaml -w /tmp/AdGuardHome >/dev/null 2>&1 &
    logger -t "AdGuardHome" "Khởi động hoàn tất trên cổng quản trị $adg_port."

    # SỬA LỖI LOGIC: Vòng lặp lưu thông minh, chờ tối đa 5 phút cho đến khi bạn setup xong lần đầu
    (
        for i in $(seq 1 60); do
            if [ -f "/etc/storage/adguardhome.yaml" ] && [ -s "/etc/storage/adguardhome.yaml" ]; then
                sleep 5 # Đợi ghi tệp xong hoàn toàn
                mtd_storage.sh save >/dev/null 2>&1
                logger -t "AdGuardHome" "Đã tự động lưu cấu hình vào Flash thành công!"
                break
            fi
            sleep 5
        done
    ) &
}

stop_adg() {
    logger -t "AdGuardHome" "Đang dừng AdGuardHome..."
    killall -9 AdGuardHome_bin 2>/dev/null
    rm -rf /tmp/AdGuardHome
    sleep 1
    
    logger -t "AdGuardHome" "Khôi phục lại tính năng DNS mặc định cho Dnsmasq..."
    sed -Ei '/port=0/d' /etc/storage/dnsmasq/dnsmasq.conf
    restart_dhcpd
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
