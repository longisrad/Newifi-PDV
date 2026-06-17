#!/bin/sh

sqm_enable=$(nvram get sqm_enable)
sqm_wan=$(nvram get sqm_wan_if)
[ -z "$sqm_wan" ] && sqm_wan="eth3"

sqm_dl=$(nvram get sqm_dl_speed)
sqm_ul=$(nvram get sqm_ul_speed)
sqm_qdisc=$(nvram get sqm_qdisc)
[ -z "$sqm_qdisc" ] && sqm_qdisc="fq_codel"

stop_sqm() {
    logger -t "SQM" "Đang dừng SQM..."
    # Xóa hàng đợi giới hạn trên cả cổng WAN vật lý và cổng ảo IFB
    tc qdisc del dev $sqm_wan root 2>/dev/null
    tc qdisc del dev $sqm_wan ingress 2>/dev/null
    tc qdisc del dev ifb0 root 2>/dev/null
    ip link set dev ifb0 down 2>/dev/null
    
    hwnat_mode=$(nvram get hw_nat_mode)
    if [ "$hwnat_mode" != "0" ] && [ -n "$hwnat_mode" ]; then
        logger -t "SQM" "Đang khôi phục lại Hardware NAT hệ thống..."
        rc hw_nat start
    fi
}

start_sqm() {
    [ "$sqm_enable" != "1" ] && return
    [ -z "$sqm_dl" ] && sqm_dl="0"
    [ -z "$sqm_ul" ] && sqm_ul="0"
    
    logger -t "SQM" "Tạm dừng Hardware NAT để xử lý hàng đợi qua CPU..."
    rc hw_nat stop
    sleep 1

    logger -t "SQM" "Khởi chạy SQM trên $sqm_wan (DL: ${sqm_dl}Kbps, UL: ${sqm_ul}Kbps) thuật toán: $sqm_qdisc..."
    
    # 1. GIỚI HẠN TẢI LÊN (UPLOAD): Sử dụng trực tiếp egress của cổng WAN vật lý
    if [ "$sqm_ul" -gt 0 ]; then
        tc qdisc add dev $sqm_wan root handle 1: htb default 11
        tc class add dev $sqm_wan parent 1: classid 1:1 htb rate ${sqm_ul}kbit ceil ${sqm_ul}kbit
        tc class add dev $sqm_wan parent 1:1 classid 1:11 htb rate ${sqm_ul}kbit ceil ${sqm_ul}kbit
        tc qdisc add dev $sqm_wan parent 1:11 handle 11: $sqm_qdisc
    fi
    
    # 2. GIỚI HẠN TẢI XUỐNG (DOWNLOAD): Chuyển hướng luồng Ingress của WAN sang Egress của IFB0
    if [ "$sqm_dl" -gt 0 ]; then
        # Khởi động cổng ảo ifb0
        ip link set dev ifb0 up 2>/dev/null
        # Tạo bộ lọc chuyển hướng luồng tải xuống của WAN vật lý sang cổng ảo ifb0
        tc qdisc add dev $sqm_wan ingress 2>/dev/null
        tc filter add dev $sqm_wan parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb0 2>/dev/null
        
        # Áp dụng bóp giới hạn băng thông download lên cổng ảo ifb0
        tc qdisc add dev ifb0 root handle 1: htb default 11
        tc class add dev ifb0 parent 1: classid 1:1 htb rate ${sqm_dl}kbit ceil ${sqm_dl}kbit
        tc class add dev ifb0 parent 1:1 classid 1:11 htb rate ${sqm_dl}kbit ceil ${sqm_dl}kbit
        tc qdisc add dev ifb0 parent 1:11 handle 11: $sqm_qdisc
    fi
}

case "$1" in
start) start_sqm ;;
stop) stop_sqm ;;
restart) stop_sqm; sleep 1; start_sqm ;;
esac
