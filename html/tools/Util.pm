use strict;
use warnings;
use utf8;
use File::Spec;

sub parse_command_line
{
    my @enableParms = split(/ /,shift);
    my $args = {};
    while($_ = shift)
    {
        if(/^-(\w)$/)
        {
            my $arg = $1;
            if($_[0] && $_[0] =~ /^[^-]/)        
            {
                $args->{$arg} = shift;
            }
            else
            {
                $args->{$arg} = 1;
            }
        }
        elsif(/^-(\w+)$/)
        {
            my $arg = $1;
            $args->{$_} = 1 foreach(split(//,$arg));
        }
        elsif(/^--(\w+)$/)
        {
            my $arg = $1;
            if($_[0] && $_[0] =~ /^[^-]/)    
            {
                $args->{$arg} = shift;
            }
            else
            {
                $args->{$arg} = 1;
            }
        }
        else
        {
            $args->{error} = "error formmat!";
            return $args;
        }
    }
    foreach(keys %$args)
    {
        my $arg = $_;
        my $find = 0;
        foreach(@enableParms)
        {
            if($arg eq $_)
            {
                $find = 1;
                last;
            }
        }
        if(!$find)
        {
            $args->{error} = "unknow option:$arg";
            return $args;
        }
    }
    return $args;
}

sub create
{
    my($path) = @_;
    #print "create: $path\n";
    if(open(OUT, ">", $path))
    {
        close(OUT);
    }
    else
    {
        my @dirs;
        my $tmpPath;
        if($^O eq 'MSWin32')
        {
            @dirs = split("\\\\", $path);
            $tmpPath = $dirs[0];
        }
        else
        {
            @dirs = split("\/", $path);
            $dirs[0] = "\/";
            $tmpPath = $dirs[0];
        }
        #print "dirs: ",join("#", @dirs),"\n";
        die "errer path:$path" if(!scalar(@dirs));
        for(my $i = 1;$i < scalar(@dirs) - 1; $i++)
        {
            #print $_,"\n";
            $tmpPath = File::Spec->catfile($tmpPath, $dirs[$i]); 
            if(! -e $tmpPath)
            {
                #print "not exit: $tmpPath\n";
                mkdir $tmpPath ;
            }
        }
    }
}

1;
