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
    tc qdisc del dev $sqm_wan root 2>/dev/null
    tc qdisc del dev $sqm_wan ingress 2>/dev/null
    
    # Kiểm tra cấu hình gốc của người dùng. Nếu họ bật HWNAT thì mới khôi phục lại
    hwnat_mode=$(nvram get hw_nat_mode)
    if [ "$hwnat_mode" != "0" ] && [ -n "$hwnat_mode" ]; then
        logger -t "SQM" "Đang khôi phục lại Hardware NAT hệ thống..."
        rc hw_nat start
    fi
}

start_sqm() {
    [ "$sqm_enable" != "1" ] && return
    
    logger -t "SQM" "Tạm dừng Hardware NAT để CPU xử lý hàng đợi SQM..."
    rc hw_nat stop
    sleep 1

    logger -t "SQM" "Khởi chạy SQM trên $sqm_wan (DL: ${sqm_dl}Kbps, UL: ${sqm_ul}Kbps) thuật toán: $sqm_qdisc..."
    
    if [ "$sqm_ul" -gt 0 ]; then
        tc qdisc add dev $sqm_wan root handle 1: htb default 11
        tc class add dev $sqm_wan parent 1: classid 1:1 htb rate ${sqm_ul}kbit ceil ${sqm_ul}kbit
        tc class add dev $sqm_wan parent 1:1 classid 1:11 htb rate ${sqm_ul}kbit ceil ${sqm_ul}kbit
        tc qdisc add dev $sqm_wan parent 1:11 handle 11: $sqm_qdisc
    fi
}

case "$1" in
start) start_sqm ;;
stop) stop_sqm ;;
restart) stop_sqm; sleep 1; start_sqm ;;
esac
