use strict;
use warnings;
use utf8;
use File::Spec;

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
        print "dirs: ",join("#", @dirs),"\n";
        die "errer path:$path" if(!scalar(@dirs));
        for(my $i = 1;$i < scalar(@dirs) - 1; $i++)
        {
            print $_,"\n";
            $tmpPath = File::Spec->catfile($tmpPath, $dirs[$i]); 
            if(! -e $tmpPath)
            {
                print "not exit: $tmpPath\n";
                mkdir $tmpPath ;
            }
        }
    }
}

1;
