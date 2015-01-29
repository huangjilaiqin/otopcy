use strict;
use warnings;
use utf8;
use Image::Size;

use Util;

my $enableParms = "path type h";
my $params = parse_command_line($enableParms,@ARGV);

if($params->{h} || !$params->{path} || !$params->{type})
{
    help();
    exit;
}

my $imgStr = `perl ls.pl -f "$params->{path}" -p "$params->{type}"`;
my @imgs = split("\n", $imgStr);

for(@imgs)
{
    s/^\s+|\s+$//g;
    my $image = $_;
    my ($x, $y) = imgsize($image);
    next if($x != 1000 || $y != 1000);

    $image =~ /^(.*)[\/\\]([^\/\\]+)\.($params->{type})$/;
    my $imgPath = $1;
    my $imgName = $2;
    my $imgType = $3;
    #print "$imgPath\n$imgName\n$imgType\n";
    chdir $imgPath;
    `convert -resize 850x850 "$imgName.$imgType" "${imgName}_bg.$imgType"` if(!-e "${imgName}_bg.$imgType");
    `convert -resize 350x350 "$imgName.$imgType" "${imgName}_md.$imgType"` if(!-e "${imgName}_md.$imgType");
    `convert -resize 65x65 "$imgName.$imgType" "${imgName}_sm.$imgType"` if(!-e "${imgName}_sm.$imgType");
}

sub help
{
    print STDERR<<EOF;
    usage 
        --path          file path,separate with comma(,).
        --type          handle the file type where is "path" appoint.
EOF
}
