use strict;
use warnings;
use utf8;
use Config::IniFiles;
use Image::Size;
use Data::Dumper;



# IniFiles的用法
#my $cfg = Config::IniFiles->new( -file => "$path\\test.ini" );
#my @lines = $cfg->val('test','test1');
#tie %ini, 'Config::IniFiles', ( -file => "$path\\test.ini" );
#for(sort {$a <=> $b} keys %{$ini{picture}})
#{
#    my $index = $_;
#    my $value = $ini{picture}{$index};
#    print $value,"\n";
#}

#ImageMagick使用
#获取像素大小
my ($x, $y) = imgsize("5w bulb light 6000-6500k.jpg");
#print "$x $y\n";

#图片按比例缩放到指定宽高
#my $imgName = "1_sm";
#my $imgType = "jpg";
#
#`convert -resize 850x850 "$imgName.$imgType" "${imgName}_bg.$imgType"`;
#`convert -resize 350x350 "$imgName.$imgType" "${imgName}_md.$imgType"`;
#`convert -resize 65x65 "$imgName.$imgType" "${imgName}_sm.$imgType"`;

#添加水印
#`composite -gravity center bg.jpg fg.jpg 123_center.jpg`;
#`composite -gravity north bg.jpg fg.jpg 123_north.jpg`;
#`composite -gravity northeast bg.jpg fg.jpg 123_northeast.jpg`;

my @a = ();
$a[0] = 0;
print "test:\n".join("\n", @a);
