<!DOCTYPE html>
<html>
<head>
<title>Padavan - AdGuard Home</title>
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
<input type="hidden" name="current_page" value="Advanced_adguardhome.asp">
<input type="hidden" name="next_page" value="Advanced_adguardhome.asp">
<input type="hidden" name="action_mode" value=" Apply ">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_service" value="restart_adg">

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
                    <td class="panel_header">Cấu hình dịch vụ AdGuard Home</td>
                </tr>
                <tr>
                    <td class="panel_body">
                        <table width="100%" border="0" cellpadding="4" cellspacing="0">
                            <tr>
                                <td width="50%">Kích hoạt AdGuard Home:</td>
                                <td>
                                    <select name="adg_enable" class="input">
                                        <option value="0" <% nvram_match_x("", "adg_enable", "0", "selected"); %>>Tắt</option>
                                        <option value="1" <% nvram_match_x("", "adg_enable", "1", "selected"); %>>Bật</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>Cổng truy cập WebUI:</td>
                                <td>
                                    <input type="text" name="adg_port" class="input" value="<% nvram_get_x("", "adg_port"); %>" size="10" maxlength="5">
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
