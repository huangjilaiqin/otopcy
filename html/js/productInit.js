$(function() {
    initMenu($("#productMenu"), showSubmenu, hiddenSubmenu, "product-menu");

    $("#navLight").mouseenter(function() {
        var top = parseInt($(this).css("top")) + parseInt($(this).css("height"));
        $("#productMenu").css({
            "display": "block",
            "top": top + "px",
        });
    }).mouseleave(function() {
        $("#productMenu").css({
            "display": "none",
        });

    });

    $("#productMenu").mouseenter(function() {
        $(this).css({
            "display": "block",
        });
    }).mouseleave(function() {
        $(this).css({
            "display": "none",
        })
    });


    $(".jqzoom").imagezoom({
        offset: 10,
        xzoom: 430,
        yzoom: 430,
    });

    $("#thumblist li a").mouseover(function() {
        $(this).parents("li").addClass("tb-selected")
            .siblings().removeClass("tb-selected");
        $(".jqzoom").attr('src', $(this).find("img").attr(
            "mid"));
        $(".jqzoom").attr('rel', $(this).find("img").attr(
            "big"));
    });

});
