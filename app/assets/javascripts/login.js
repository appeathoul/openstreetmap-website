$(document).ready(function () {
  // Preserve location hash in referer
  if (window.location.hash) {
    $("#referer").val($("#referer").val() + window.location.hash);
  }

  getChromeVersion()

  // Attach referer to authentication buttons
  $(".auth_button").each(function () {
    var params = querystring.parse(this.search.substring(1));
    params.referer = $("#referer").val();
    this.search = querystring.stringify(params);
  });

  // Add click handler to show OpenID field
  $("#openid_open_url").click(function () {
    $("#openid_url").val("http://");
    $("#login_auth_buttons").hide();
    $("#login_openid_url").show();
    $("#login_openid_submit").show();
  });

  // Hide OpenID field for now
  $("#login_openid_url").hide();
  $("#login_openid_submit").hide();

  // Handle OpenID submission by redirecting to omniauth
  $("#openid_login_form").submit(function () {
    var action = $(this).prop("action"),
      openid_url = $(this).find("#openid_url").val(),
      referer = $(this).find("#openid_referer").val(),
      args = {};
    args.openid_url = openid_url;
    if (referer) {
      args.referer = referer;
    }
    window.location = action + "?" + querystring.stringify(args);
    return false;
  });

  

  function getChromeVersion() {
    var arr = navigator.userAgent.split(' ');
    var chromeVersion = '';
    for (var i = 0; i < arr.length; i++) {
      if (/chrome/i.test(arr[i]))
        chromeVersion = arr[i]
    }
    if (chromeVersion) {
      return Number(chromeVersion.split('/')[1].split('.')[0]);
    } else {
      return false;
    }
  }
  var userAgent = window.navigator.userAgent;
  var isNotOk = true;
  if (userAgent.indexOf("Chrome") > -1) {
    var version = getChromeVersion();
    if (version >= 54) {
      isNotOk = false;
    }
    else {
      alert('您使用的谷歌浏览器版本过低，为了更好地体验请将浏览器升级到新版本！');
    }
  }
  else {
    alert('为了更好地体验,推荐您使用谷歌浏览器！');
  }
  if (isNotOk) {
    var ask = confirm("请问您是64位操作系统么？");
    if (ask === true) {
      window.open("/attachments/chrome/chrome_x32_v74.0.3729.131_installer.exe", "newwindow");
    } else {
      window.open("/attachments/chrome/chrome_x64_v74.0.3729.131_installer.exe", "newwindow");
    }
    //window.location.href="about:blank"
    window.stop();
  }
});
