<!DOCTYPE html>
<html>
<head>
<title>Padavan - SQM QoS</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="stylesheet" type="text/css" href="as.css">
<link rel="stylesheet" type="text/css" href="as_menu.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
function initial(){
    show_menu();
}
function applyRule(){
    showLoading(5);
    document.form.action_mode.value = " Apply ";
    document.form.submit();
}
</script>
</head>

<body onload="initial();" class="bg">
<div id="Loading" class="popup_bg"></div>
<form method="post" name="form" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Advanced_SQM.asp">
<input type="hidden" name="next_page" value="Advanced_SQM.asp">
<input type="hidden" name="action_mode" value=" Apply ">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_service" value="restart_sqm">

<table class="content" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td width="17%">&nbsp;</td>
        <td valign="top" width="66%">
            <div id="main_menu" class="main_menu"></div>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td valign="top">
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="panel">
                <tr>
                    <td class="panel_header">Cấu hình Smart Queue Management (SQM)</td>
                </tr>
                <tr>
                    <td class="panel_body">
                        <table width="100%" border="0" cellpadding="4" cellspacing="0">
                            <tr>
                                <td width="50%">Kích hoạt SQM:</td>
                                <td>
                                    <select name="sqm_enable" class="input">
                                        <option value="0" <% nvram_match_x("", "sqm_enable", "0", "selected"); %>>Tắt</option>
                                        <option value="1" <% nvram_match_x("", "sqm_enable", "1", "selected"); %>>Bật</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>Cổng mạng áp dụng (Interface):</td>
                                <td>
                                    <select name="sqm_wan_if" class="input" style="width: 250px;">
                                        <!-- Mạng dây WAN truyền thống -->
                                        <option value="eth3" <% nvram_match_x("", "sqm_wan_if", "eth3", "selected"); %>>Mạng dây WAN truyền thống (eth3)</option>
                                        
                                        <!-- Mạng quay số PPPoE -->
                                        <option value="ppp0" <% nvram_match_x("", "sqm_wan_if", "ppp0", "selected"); %>>Mạng quay số PPPoE (ppp0)</option>
                                        
                                        <!-- Mạng không dây Kích sóng (Wifi Relay 2.4GHz) -->
                                        <option value="apcli0" <% nvram_match_x("", "sqm_wan_if", "apcli0", "selected"); %>>Kích sóng Wifi 2.4GHz (apcli0)</option>
                                        
                                        <!-- Mạng không dây Kích sóng (Wifi Relay 5GHz) -->
                                        <!-- apclib0 dùng cho driver mở, apclii0/apclix0 dùng cho driver mtk gốc -->
                                        <option value="apclii0" <% nvram_match_x("", "sqm_wan_if", "apclii0", "selected"); %>>Kích sóng Wifi 5GHz (apclii0 / Driver MTK)</option>
                                        <option value="apclix0" <% nvram_match_x("", "sqm_wan_if", "apclix0", "selected"); %>>Kích sóng Wifi 5GHz (apclix0 / Driver MTK)</option>
                                        <option value="apclib0" <% nvram_match_x("", "sqm_wan_if", "apclib0", "selected"); %>>Kích sóng Wifi 5GHz (apclib0 / Driver Open)</option>
                                        
                                        <!-- Mạng di động cắm qua cổng USB 3G/4G -->
                                        <option value="usb0" <% nvram_match_x("", "sqm_wan_if", "usb0", "selected"); %>>Modem USB 4G LTE - RNDIS (usb0)</option>
                                        <option value="ncm0" <% nvram_match_x("", "sqm_wan_if", "ncm0", "selected"); %>>Modem USB 4G LTE - NCM (ncm0)</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>Tốc độ Tải xuống giới hạn (Kbps):</td>
                                <td>
                                    <input type="text" name="sqm_dl_speed" class="input" value="<% nvram_get_x("", "sqm_dl_speed"); %>" size="10">
                                </td>
                            </tr>
                            <tr>
                                <td>Tốc độ Tải lên giới hạn (Kbps):</td>
                                <td>
                                    <input type="text" name="sqm_ul_speed" class="input" value="<% nvram_get_x("", "sqm_ul_speed"); %>" size="10">
                                </td>
                            </tr>
                            <tr>
                                <td>Thuật toán xếp hàng (Queue Discipline):</td>
                                <td>
                                    <select name="sqm_qdisc" class="input">
                                        <option value="fq_codel" <% nvram_match_x("", "sqm_qdisc", "fq_codel", "selected"); %>>fq_codel (Khuyên dùng)</option>
                                        <option value="cake" <% nvram_match_x("", "sqm_qdisc", "cake", "selected"); %>>cake (Cần kernel hỗ trợ)</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center" style="padding-top:15px;">
                                    <input type="button" class="button" value="Áp dụng" onclick="applyRule();">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</form>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
</body>
</html>
