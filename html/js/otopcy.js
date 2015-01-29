function showSubmenu() {
    //console.log($(this).attr("id"));
    var top = parseInt($(this).offset().top);
    var left = parseInt($(this).offset().left) + parseInt($(this).css("width"));
    var height = parseInt($(this).children("ul").css("height"));
    //console.log($(this).children("ul").length);

    //console.log("maxALeight:" + maxALeight);
    console.log("id:" + $(this).attr("id"));
    console.log("top:" + top + ",left:" + left);
    $(this).children("ul").css({
        "top": top + "px",
        "left": left + "px",
        "height": 0,
        "position": "fixed",
        "display": "block"
    }).animate({
        "height": height + "px"
    }, "normal");

}

function hiddenSubmenu() {
    //console.log($(this).attr("id"));
    $(this).children("ul").fadeOut("fast");
}

function isMove2Target(target, x, y) {
    var mixX = parseInt(target.offset().left);
    var maxX = mixX + parseInt(target.css("width"));

    var mixY = parseInt(target.offset().top);
    var maxY = mixY + parseInt(target.css("height"));

    console.log(mixX + "," + maxX + "," + mixY + "," + maxY);
    console.log(x, y);
    if (x < mixX || x > maxX || y < mixY || y > maxY) {
        console.log(0);
        return 0;
    }
    console.log(1);
    return 1;
}

function initMenu(menu, showSubmenu, hiddenSubmenu, className) {
    //$.each(menu.find("a"), function(n, v) {
    //    console.log($(v).outerWidth());
    //});
    //menu.addClass("resetMenu");
    ////menu.addClass("yui3-cssreset");
    //console.log("addClass");
    //$.each(menu.find("a"), function(n, v) {
    //    console.log($(v).outerWidth());
    //});
    //在取得a标签长度的时候必须不能有任何样式，否则无法获取a标签中文字真正的宽度
    initSubmenu(menu, showSubmenu, hiddenSubmenu);

    
    menu.addClass(className);
    //menu.find("a").css({
    //    "display": "block",
    //    "padding": "8px 5px 8px 20px",
    //});
    menu.find("ul").css({
        "display": "none"
    });
}

function initSubmenu(menu, showSubmenu, hiddenSubmenu) {

    //console.log(menu.attr("id"));
    var maxALeight = getMaxMenuItemLength(menu);
    maxALeight += 50;
    //console.log("maxALeight:" + maxALeight);

    $.each(menu.children("li"), function(n, child) {

        if ($(child).children("ul").length != 0) {
            $(child).mouseenter(showSubmenu);
            $(child).mouseleave(hiddenSubmenu);
            $.each($(child).children("ul"), function(n, child) {
                initSubmenu($(child), showSubmenu, hiddenSubmenu);
            });
        }
    });
    //设置ul的width必须从嵌套最深的开始往外设置，若从最外面开始设置则会嵌套a标签的长度。
    menu.css({
        "width": maxALeight + "px"
    });
    
}

function getMaxMenuItemLength(menu) {
    var maxALeight = 0;
    //console.log("a length:" + $(menu).find("a").length);
    $.each($(menu).children("li").children("a"), function(n, v) {
        var width = parseInt($(v).outerWidth());
        //console.log("a width:" + width);
        if (width > maxALeight) maxALeight = width;
    });
    return maxALeight;
}
