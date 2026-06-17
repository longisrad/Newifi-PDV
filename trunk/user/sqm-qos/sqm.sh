#!/bin/sh

sqm_enable=$(nvram get sqm_enable)
sqm_wan=$(nvram get sqm_wan_if)
[ -z "$sqm_wan" ] && sqm_wan="eth3"

sqm_dl=$(nvram get sqm_dl_speed)
sqm_ul=$(nvram get sqm_ul_speed)
sqm_qdisc=$(nvram get sqm_qdisc)
[ -z "$sqm_qdisc" ] && sqm_qdisc="fq_codel"

stop_sqm() {
    logger -t "SQM" "Đang dừng SQM và khôi phục Hardware NAT..."
    tc qdisc del dev $sqm_wan root 2>/dev/null
    tc qdisc del dev $sqm_wan ingress 2>/dev/null
    
    # Kích hoạt lại Hardware NAT để khôi phục hiệu năng tối đa
    rc hw_nat start
}

start_sqm() {
    [ "$sqm_enable" != "1" ] && return
    
    logger -t "SQM" "Tạm dừng Hardware NAT để CPU xử lý hàng đợi SQM..."
    # Tắt Hardware NAT (Bắt buộc để lệnh tc hoạt động định tuyến qua CPU)
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
