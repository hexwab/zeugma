#!/usr/bin/perl -w
#my $file = shift ||"timR08.bdf";

my $bdf = do { local $/=undef;<> };

my @ch=split/\n\n/,$bdf;
my @b;
my (%chars, %widths);
my @fbbox;
for my $ch (@ch) {
    my %h;
    for(split/\n/, $ch) {
	/^[0-9A-F]+$/&&push @{$h{bm}},$_ and next if /^BITMAP$/../^ENDCHAR/;
	/^([A-Z_]+) (.*)$/;# or die $_;
	$h{lc$1}=$2 if $1;
	if ($1 && lc$1 eq 'fontboundingbox') {
	    ($fwidth,$fheight,$xoffset,$yoffset)=split/ /, $h{lc$1};
	}
    }

    if ($h{bm}) {
	my $e=$h{encoding};
	$chars{$e}=$h{bm};
	$_.='00' for @{$chars{$e}}; # add a byte of padding
	$h{dwidth}=~/(\d+) (\d+)/ or die;
	$widths{$e}=$1;
	die "$e: $widths{$e}" unless $widths{$e}<=16;
	my ($w,$h,$xoff,$yoff)=split/ /,$h{bbx};
	$xoff-=$xoffset;
	$yoff-=$yoffset;
	print "adding $yoff vertical px\n";
	#print join",",@{$chars{$e}};
	#print "\n";
	for my $y (0..$yoff-1) {
	    push @{$chars{$e}},'0000';
	}
	#print "$e $h{bbx}\n";
	#print join",",@{$chars{$e}};
	#print "\n";
	die "$e: $fheight ".scalar@{$chars{$e}} if scalar@{$chars{$e}}>$fheight;
	while (@{$chars{$e}}<$fheight) {
	    unshift @{$chars{$e}},'0000';
	}
    }
    push @b, \%h;
}
use Data::Dumper;
print Dumper \@b;


my @c=(32..126);#,160..255);

my $ptr=2+2*(scalar @c);
my %ptrs;
my %encs;
for my $e (@c) {
    my @enc;
    my @ch=@{$chars{$e}} or die $e;# next;
    print "enc($e) (w $widths{$e})=";

    @enc=map {/([0-9A-F]{2})/ or die; hex $1} @ch; # first byte

    if ($widths{$e}>8) {
	#print "[ch=".join(":",@ch)."]";
	# maybe second byte
	push @enc, $_ for map {/[0-9A-F]{2}([0-9A-F]{2})/ or die $_ ; hex $1} @ch;
    }
	print join",",@enc;
    my $enc=pack"C*", @enc;
    $encs{$e}=$enc;
    $ptrs{$e} = $ptr +(($widths{$e}-1)<<12);
    printf "[ptr=%x enc=%x]", $ptr, $ptrs{$e};
    $ptr+=length $enc;
    print "\n";
}

{
    
    open my $c,">chars" or die;
    print $c pack"C*",(scalar @c),$fheight; # header: nchars, height
    for my $e (@c) {
	# pointers lsb
	print $c pack'C',$ptrs{$e}&255;
    }    
    for my $e (@c) {
	# pointers msb
	print $c pack'C',$ptrs{$e}>>8;
    }    

    for my $e (@c) {
#	print $w chr $widths{$e};
#	print $c pack"C*", map {/([0-9A-F]{2})/ or die; hex $1} @ch;
	print $c $encs{$e};
    }
}
