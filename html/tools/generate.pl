use strict;
use warnings;
use utf8;
use File::Spec;
use Data::Dumper;
use XML::LibXML;
use Config::IniFiles;
use Util;

my %globalIni;
tie %globalIni, 'Config::IniFiles', ( -file => "global.ini" ) or die "global.ini is not exist";

#css
#js
#images
#    icon
#    products
#en
#    products
#zh
#    products
#

my $enableArgs = "host websitepath";
my $args = parse_command_line($enableArgs, @ARGV);

for(split(";",$globalIni{globalConf}{lang}))
{
    my $lang = $_;
    my $navMenu = generateNavMenu(catfile($args->{websitepath},$lang, "products"), caturl($args->{host},$lang, "products"), catfile($args->{websitepath},"images","products"));
    generateProductHtml(catfile($args->{websitepath},$lang, "products"), caturl($args->{host},$lang, "products"), catfile($args->{websitepath},"images","products"), caturl($args->{host}, "images", "products"), $navMenu);
    generateProductsHtml($navMenu);
}

sub generateProductHtml
{
    my($productPrefixPath, $productPrefixUrl, $picPrefixPath, $picPrefixUrl, $navMenu) = @_;
    print "generateProductHtml ...\n";

    #获取配置文件detail.ini数组
    print "get detail.ini files at:$picPrefixPath ...\n";
    my $picConfigs = getProductsConfig($picPrefixPath);
    #print join("\n", @$picConfigs),"\n";
    my $matchPicPrefixPath = $picPrefixPath;
    $matchPicPrefixPath =~ s/\\/\\\\/g;
    $matchPicPrefixPath =~ s/\//\\\//g;
    #print $matchPicPrefixPath ,"\n";

    open(IN, "<", "productHeader.html") or die "can't open productHeader.html";
    my @lines = <IN>;
    close(IN);
    my $productHeader = join("", @lines);

    open(IN, "<", "navBar.html") or die "can't open navBar.html";
    @lines = <IN>;
    close(IN);
    my $navBar = join("", @lines);

    open(IN, "<", "navMenu.html") or die "can't open navMenu.html";
    @lines = <IN>;
    close(IN);
    my $navMenuHtml = join("", @lines);

    open(IN, "<", "bread.html") or die "can't open bread.html";
    @lines = <IN>;
    close(IN);
    my $bread = join("", @lines);

    open(IN, "<", "foot.html") or die "can't open foot.html";
    @lines = <IN>;
    close(IN);
    my $foot = join("", @lines);

    my $productCategory = {};

    for(@$picConfigs)
    {
        my $iniPath = $_;
        #print "picPath:$picPath\n";
        #读取产品配置文件
        my %productIni;
        tie %productIni, 'Config::IniFiles', ( -file => $iniPath );
        if(! scalar(keys %{$productIni{picture}}))
        {
            warn("detail.ini:$iniPath has no picture!");
            next;
        }
        #print "picPath:$picPath\n";

        $iniPath =~ /(.*)detail\.ini$/;
        #产品的系统路径名
        my $productPath = $1;

        #去掉系统路径前缀
        $productPath =~ s/$matchPicPrefixPath//;

        $productPath =~ /(.*)[\\|\/]([^\\\/]+)[\\|\/]?$/;
        my $category = $1;
        my $productTitle = $2;
        $category =~ s/^\/+|\\+$//g;
        #print "productPath:$productPath\n" if(!$category);
        #产品的名字

        my @categoryNames;
        if($category =~ /\//)
        {
            my $tmp = $category;
            $tmp =~ s/^\/+|\/+$//;
            @categoryNames = split("\\\/",$tmp);
        }
        else
        {
            my $tmp = $category;
            $tmp =~ s/^\\+|\\+$//;
            @categoryNames = split("\\\\",$tmp);
        }
        my $tmpMenu = $navMenu;
        for(@categoryNames)
        {
            my $categoryName = $_;
            $tmpMenu = $tmpMenu->{subMenu}->{$categoryName};
        }
        $tmpMenu->{products} = [] if(!$tmpMenu->{products});
        my $products = $tmpMenu->{products};
        #print "categoryNames:\n",Data::Dumper->Dumper(@categoryNames);
        my $product;
        
        #if($productIni{title})
        #{
        #    #将html文件路径中的产品名称替换成配置文件detail.ini中的title
        #    $productPath =~ s/$productTitle/$productIni{title}/;
        #    $productTitle = $productIni{title};
        #}

        my $productUrl = $productPath;
        $productUrl =~ s/^\\|\\$//g;
        $productUrl .= ".html";
        #产品url路径
        my $productUrl = caturl($productPrefixUrl, split("\\\\",$productUrl));
        $product->{url} = $productUrl;

        #产品html文件系统路径
        $productPath = File::Spec->catfile($productPrefixPath, "$productPath");
        $productPath .= ".html";

        create($productPath);
        open(HTML, ">", "$productPath") or die "can't open $productPath, $!";
        print HTML "<html lang=\"$globalIni{globalConf}{lang}\">\n";
        print HTML "<head>\n";
        print HTML "<meta name=\"keywords\" content=\"$productIni{seo}{keywords}\"\/>\n";
        print HTML "<meta name=\"description\" content=\"$productIni{seo}{description}\"\/>\n";
        print HTML "<title>$productTitle<\/title>\n";
        print HTML $productHeader;
        print HTML "<\/head>\n";
        print HTML "<body>\n";
        print HTML $navBar;
        print HTML $navMenuHtml;
        print HTML $bread;
        #具体产品内容
        print HTML "<div class=\"product-content\">
                        <div class=\"zoom-box\">
                            <div class=\"tb-booth tb-pic\">
                            ";
                                my ($mainPicName, $mainAlt) = split(":", $productIni{picture}{1}); 
                                error("path: $iniPath\n error line: $productIni{picture}{1}") if(!$mainPicName || !$mainAlt);
                                my $mainPicPath = catfile($picPrefixPath, $category, $productTitle, $mainPicName);
                                error("picture is not exist,path: $mainPicPath \n$picPrefixPath \n$category \n$productTitle \n$mainPicName") if(!-e $mainPicPath);
                                my $mainPicUrl = caturl($picPrefixUrl, @categoryNames, $productTitle, $mainPicName);
                                $mainPicUrl =~ /^(.*)(\.\w+)$/;
                                $mainPicUrl = $1;
                                my $picType = $2;
                                $product->{img} = "${mainPicUrl}_md${picType}";
                                $product->{imgAlt} = $mainAlt;
                                print HTML "<a href=\"#\"><img src=\"${mainPicUrl}_md${picType}\" rel=\"${mainPicUrl}_bg${picType}\" alt=\"$mainAlt\" class=\"jqzoom\" \/>";
                                print HTML "<\/a>
                            <\/div>
                            <ul class=\"tb-thumb\" id=\"thumblist\">
                            ";

                                for(values %{$productIni{picture}})
                                {
                                    #print "$_\n";
                                    print HTML 
                                        "<li class=\"tb-selected\">
                                            <div class=\"tb-pic\">";
                                            my $value = $_;
                                            my ($picName, $picAlt) = split(":", $value); 
                                            error("path: $iniPath\n error line: $value") if(!$picName || !$picAlt);
                                            my $picPath = catfile($picPrefixPath, $category, $productTitle, $picName);
                                            error("picture is not exist,path: $picPath") if(!-e $picPath);
                                            my $picUrl = caturl($picPrefixUrl, $category,$productTitle, $picName);
                                            $picUrl =~ /^(.*)(\.\w+)$/;
                                            $picUrl = $1;
                                            my $picType = $2;
                                        print HTML "<a href=\"#\"><img src=\"${picUrl}_sm${picType}\" alt=\"$picAlt\" mid=\"${picUrl}_md${picType}\" big=\"${picUrl}_bg${picType}\"><\/a>
                                            <\/div>
                                        <\/li>\n";
                                }
                            print HTML "<\/ul>
                        <\/div>
                        ";

                        print HTML "<div class=\"product-detail\">
                            <div class=\"product-title\">
                                $productTitle
                            <\/div>
                            <div class=\"product-properties\">
                            ";
                            for(sort{$a <=> $b} keys %{$productIni{parameters}})
                            {
                                my ($propertyName, $propertyValue) = split(":", $productIni{parameters}{$_});
                                error("path: $iniPath\n error line: $productIni{parameters}{$_}") if(!$propertyName || !$propertyValue);
                                print HTML 
                                "<div class=\"property\">
                                    <div class=\"name\">
                                        $propertyName
                                    <\/div>
                                    <div class=\"value\">
                                    ";
                                        for(split(",", $propertyValue))
                                        {
                                            print HTML "<p>$_<\/p>\n";
                                        }
                                   print HTML "<\/div>
                                <\/div>
                                ";
                            }
                            print HTML "<\/div>
                        <\/div>
                    <\/div>
                    ";
        print HTML $foot;
        print HTML "<\/body>";
        print HTML "<\/html>";
        close(HTML);
        push @$products, $product;
    }
}

sub generateProductsHtml
{
    my ($navMenu) = @_;
    print "generateProductsHtml ...\n";
    my %categoryIni;
    my $categoryIniPath = File::Spec->catfile($navMenu->{categoryPath}, "category.ini");
    if(! -e $categoryIniPath)
    {
        #print "not exit iniPath:$categoryIniPath\n";
        #递归子分类
        for(keys %{$navMenu->{subMenu}})
        {
            my $categoryName = $_;
            my $menu = $navMenu->{subMenu}->{$categoryName};
            generateProductsHtml($menu);
        }
        return;
    }
    tie %categoryIni, 'Config::IniFiles', ( -file => $categoryIniPath);

    open(IN, "<", "productsHeader.html") or die "can't open productsHeader.html";
    my @lines = <IN>;
    close(IN);
    my $productsHeader = join("", @lines);

    open(IN, "<", "navBar.html") or die "can't open navBar.html";
    @lines = <IN>;
    close(IN);
    my $navBar = join("", @lines);

    open(IN, "<", "navMenu.html") or die "can't open navMenu.html";
    @lines = <IN>;
    close(IN);
    my $navMenuHtml = join("", @lines);

    open(IN, "<", "bread.html") or die "can't open bread.html";
    @lines = <IN>;
    close(IN);
    my $bread = join("", @lines);

    open(IN, "<", "foot.html") or die "can't open foot.html";
    @lines = <IN>;
    close(IN);
    my $foot = join("", @lines);

    my $categoryHtml = File::Spec->catfile($navMenu->{categoryHtmlPath}, "$navMenu->{categoryName}.html");
    open(HTML, ">", $categoryHtml) or die "can't open $categoryHtml";
    print HTML "<html lang=\"$globalIni{globalConf}{lang}\">\n";
    print HTML "<head>\n";
    print HTML "<meta name=\"keywords\" content=\"$categoryIni{seo}{keywords}\"\/>\n";
    print HTML "<meta name=\"description\" content=\"$categoryIni{seo}{description}\"\/>\n";
    
    print HTML "<title>$navMenu->{categoryName}<\/title>\n";
    print HTML $productsHeader;
    print HTML "<\/head>\n";
    print HTML "<body>\n";
    print HTML $navBar;
    print HTML $navMenuHtml;
    print HTML "<div class=\"container\" style=\"padding-top:83px;\">\n";
        print HTML "<div class=\"row\">\n";
            print HTML $bread;
        print HTML "<\/div>\n";

        print HTML "<div class=\"row\">\n";
            #具体产品内容
            #添加该分类页面的产品
            for(@{$navMenu->{products}})
            {
                my $product = $_;
                print HTML "<div class=\"my-col col-sm-6 col-md-4 col-lg-4\">\n";
                    print HTML "<div class=\"thumbnail\">\n";
                        print HTML "<div class=\"cover\">\n";
                            print HTML "<a href=\"$product->{url}\" title=\"$product->{title}\" target=\"_blank \">\n";
                                print HTML "<img data-src=\"$product->{img}\" src=\"$product->{img}\" alt=\"$product->{imgAlt}\">\n";
                            print HTML "<\/a>\n";
                        print HTML "<\/div>\n";
                        print HTML "<div class=\"caption \">\n";
                            print HTML "<h3>\n"; 
                                print HTML "<a href=\"$product->{url}\" title=\"$product->{title}\" target=\"_blank \">$product->{title}<\/small><\/a>\n";
                            print HTML "<\/h3>\n";
                        print HTML "<\/div>\n";
                    print HTML "<\/div>\n";
                print HTML "<\/div>\n";
            }
        print HTML "<\/div>\n";
    print HTML "<\/div>\n";
    
    print HTML $foot;

    #递归子分类
    for(keys %{$navMenu->{subMenu}})
    {
        my $categoryName = $_;
        my $menu = $navMenu->{subMenu}->{$categoryName};
        generateProductsHtml($menu);
    }
}

sub getProductsConfig
{
    my($path) = @_;
    my $lines = `perl ls.pl -f $path -p "detail.ini"`; 
    my @configs = split("\n", $lines);
    return \@configs;
}

#生成导航菜单
sub generateNavMenuHash
{
    my($path, $navMenu) = @_;
    if(! defined($navMenu))
    {
        $navMenu = {};
        $navMenu->{subMenu} = {};
    }

    opendir (DIR,$path) or die "can't open dir:$path";
    $navMenu->{categoryPath} = $path;
    for(readdir DIR)
    {
        next if(/^\.\.?$/);
        my $tmpPath = File::Spec->catfile($path,$_);
        next if(! -d $tmpPath);
        next if(-e File::Spec->catfile($tmpPath, "detail.ini"));

        $navMenu->{subMenu}->{$_} = {};
        generateNavMenuHash($tmpPath, $navMenu->{subMenu}->{$_});
    }
    close(DIR);
    return $navMenu;
}

sub generateNavMenu
{
    #productPrefixPath:产品HTML在系统中的存放路径前缀
    #productPrefixUrl:产品url路径的前缀
    #imgsPath:产品图片的系统路径
    my($productPrefixPath, $productPrefixUrl, $imgsPath) = @_;

    print "generateNavMenu ...\n";
    my $matchProductPrefixPath = $productPrefixPath;
    $matchProductPrefixPath =~ s/\\/\\\\/g;
    $matchProductPrefixPath =~ s/\//\\\//g;

    my $matchProductPrefixUrl = $productPrefixUrl;
    $matchProductPrefixUrl =~ s/\\/\\\\/g;
    $matchProductPrefixUrl =~ s/\//\\\//g;

    my $matchImgsPath = $imgsPath;
    $matchImgsPath =~ s/\\/\\\\/g;
    $matchImgsPath =~ s/\//\\\//g;

    my $navMenu = generateNavMenuHash($imgsPath);
    #print Data::Dumper->Dumper($navMenu);

    my $doc = XML::LibXML::Document->new('1.0', "utf-8");
    my $root = $doc->createElement("root");
    $doc->setDocumentElement($root);

    my $category = $doc->createElement("div");
    $root->appendChild($category);
    $category->setAttribute("id","navLight");
    $category->setAttribute("class","product-category");
    my $categoryName = $doc->createElement("a");
    $category->appendChild($categoryName);
    $categoryName->appendText("Category");

    my $menuRoot ;
    my $menuNodes = [];
    push @$menuNodes, [$navMenu, undef, $productPrefixUrl];

    while(scalar(@$menuNodes))
    {
        #print "menuNodes\n";
        my $node = shift @$menuNodes;
        my $menu = $node->[0];
        my $parentNode = $node->[1];
        my $url = $node->[2];

        my $ul = $doc->createElement("ul");
        if(! defined($parentNode))
        {
            $menuRoot = $ul;
            $ul->setAttribute("id", "productMenu");
        }
        else
        {
            $parentNode->appendChild($ul);
        }
        #print Data::Dumper->Dumper($menu);
        for(keys %{$menu->{subMenu}})
        {
            my $menuName = $_;
            #print "$menuName\n";
            my $subMenu = $menu->{subMenu}->{$menuName};
            my $li = $doc->createElement("li");
            $ul->appendChild($li);
            my $a = $doc->createElement("a");
            $li->appendChild($a);
            #设置分类产品的链接
            my $categoryPrefixUrl = caturl($url, $menuName);
            my $currentUrl = caturl($categoryPrefixUrl,"$menuName.html");
            print "$categoryPrefixUrl\n$currentUrl\n";
            $a->setAttribute("href",$currentUrl);
            $a->appendText($menuName);
            #print Data::Dumper->Dumper($menu->{$menuName});
            $subMenu->{url} = $currentUrl;
            #print "url:$subMenu->{url}\n";

            my $currentHtmlPath = $categoryPrefixUrl;
            $currentHtmlPath =~ s/$matchProductPrefixUrl/$matchProductPrefixPath/;
            $currentHtmlPath =~ s/\//\\\\/g;
            $subMenu->{categoryHtmlPath} = $currentHtmlPath;

            my $currentPath = $categoryPrefixUrl;
            $currentPath =~ s/$matchProductPrefixUrl/$matchImgsPath/;
            $currentPath =~ s/\//\\\\/g;
            $subMenu->{categoryPath} = $currentPath;

            $subMenu->{categoryName} = $menuName;
            #print "url:",$subMenu->{url},"\n";

            if(scalar(keys %{$subMenu->{subMenu}}))
            {
                push @$menuNodes, [$subMenu, $li, $categoryPrefixUrl];
            }
        }
        #print scalar(@$menuNodes), "\n";
    }
    $root->appendChild($menuRoot);
    open(OUT, ">", "navmenu.html");
    my $lines = $doc->toString(2);
    $lines =~ s/(^.*?<root>)//s;
    $lines =~ s/(<\/root>$)//s;
    
    #print Data::Dumper->Dumper($navMenu);
    print OUT $lines;
    close(OUT);

    return $navMenu;
}

sub caturl
{
    my @urls = @_;
    #print "urls:",join(" ", @urls),"\n";
    my $url;
    #@urls = grep !//,@urls;
    #print scalar(@urls),":",join(":",@urls),"\n";
    if(scalar(@urls))
    {
        $urls[0] =~ s/\/+$//;  
        print join("\t", @urls),"\n";
        $url = join("\/", @urls);
        print "$url\n";
    }

    return $url;
}

sub catfile
{
    return File::Spec->catfile(@_);
}

sub error
{
    my ($msg) = @_;
    print "error! $msg\n";
    exit;
}

sub warn
{
    my ($msg) = @_;
    print "warn! $msg\n";
}
