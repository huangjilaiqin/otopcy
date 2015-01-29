
use utf8;
use strict;
use File::Spec;
use Data::Dumper;

sub usage
{
    print STDERR<<EOF;
Usage ls
    -f file path,separate with comma(,)
    -p pattern to match file,put the regular expression in the quotes(""or'')
    -P PATTERN to unMatch file,put the regular expression in the quotes(""or'')
    -e exclude file,separate with comma(,)
EOF
    exit;
}

sub ls
{
    my ($path,$pattern,$notPattern) = @_;
    if(-d $path)
    {
        opendir(DIR,$path) || die "can't open $path";
        foreach(readdir DIR)
        {
            next if(/^\.\.?$/);         #filter . and ..
            next if(/^\./);             #filter hidden files
            ls(File::Spec->catfile($path,$_),$pattern,$notPattern);
        }
        closedir(DIR);
    }
    elsif(-f $path)
    {
        do {print $path,"\n"; return;} if(!$pattern && !$notPattern);
        do {print $path,"\n"; return;} if($pattern && $notPattern && $path =~ /$pattern/ && $path !~ /$notPattern/);
        do {print $path,"\n"; return;} if($pattern && !$notPattern && $path =~ /$pattern/);
        do {print $path,"\n"; return;} if($notPattern && !$pattern && $path !~ /$notPattern/);
    }
    else
    {
        print "error path:$path\n";
    }
}

sub parse_command_line
{
    my $args = {};
    while($_ = shift)
    {
        /^-(f|-files)$/ && do {@{$args->{files}} = split(/,/,shift); next;};
        /^-(p|-pattern)$/ && do {$args->{pattern} = shift; next;};
        /^-(P|-PATTERN)$/ && do {$args->{notPattern} = shift; next;};
        /^-(e|-exclude)$/ && do{@{$args->{exclude}} = split(/,/,shift); next};
        /^-/ && do {usage; die;};
    }
    $args->{files} || usage;
    return $args;
}

#print "after modified\n";
my $args = parse_command_line(@ARGV);
foreach(@{$args->{files}})
{
    my $path = $_;
    opendir(DIR,$path) || die "can't open $path";
    foreach(readdir DIR)
    {
        next if(/^\.\.?$/);         #filter . and ..
        next if(/^\./);             #filter hidden files

        my $file = File::Spec->catfile($path,$_);
        if($args->{exclude})
        {
            my $match = 0;
            foreach(@{$args->{exclude}})
            {
                if($file =~ /$_/) {$match = 1,last;} 
            }
            next if($match);
        }
        if(-e $file)
        {
            ls($file,$args->{pattern},$args->{notPattern});
        }
        else
        {
            die "$path not exit";
        }
    }
}

#排序，相对路径
