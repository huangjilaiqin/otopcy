$(function() {
    initMenu($("#productMenu"), showSubmenu, hiddenSubmenu, "product-menu");

    $("#navLight").mouseenter(function() {
        var top = parseInt($(this).css("top")) + parseInt($(this).css("height"));
        console.log("top:" + parseInt($(this).css("top")) + "," + parseInt($(this).css("height")));
        $("#productMenu").css({
            "display": "block",
            "top": top + "px",
        });
    }).mouseleave(function() {
        console.log("leave");
        $("#productMenu").css({
            "display": "none",
        });

    });

    $("#productMenu").mouseenter(function() {
        $(this).css({
            "display": "block",
            "float": "left",
        });
    }).mouseleave(function() {
        $(this).css({
            "display": "none",
        })
    });


    $(".thumbnail ").addClass("thumbnail-shadow");
    $(".thumbnail ").mouseover(function() {
        $(this).toggleClass("thumbnail-shadow-over");
    }).mouseout(function() {
        $(this).toggleClass("thumbnail-shadow-over");
    });


});
