#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# read the custom entity and .vim DTD filenames
my($XML_ENT_FILE, $VIM_DTD_FILE) = @ARGV;

# die if files dont obey
die "The specified entity file is not readable\n" unless(-r $XML_ENT_FILE);
die "The specified .vim DTD file is not writable\n" unless(-w $VIM_DTD_FILE);

# extract entities into @list
open my $handle, '<', $XML_ENT_FILE or die $!;
my @file = <$handle>;
my @list = ();

foreach (my $i = 0; $i < @file; $i++) {
  my @split = split ' ', $file[$i];
  push @list, "'$split[1]'" if (exists($split[0]) && $split[0] eq '<!ENTITY' && $split[1] ne '%' );
}

close $handle;

# read existing entities from DTD, add them to @list, and insert into DTD file
open $handle, '<', $VIM_DTD_FILE or die $!;
my @dtd_file = <$handle>;
foreach (my $i = 0; $i < @dtd_file; $i++) {
  if($dtd_file[$i] =~ /'vimxmlentities':\s+\[(.*)\]/) {
    push @list, split ',', $1 if ($1);
    # make @list unique
    my %Seen; my @unique = grep { ! $Seen{$_}++ } @list;
    my $xmlents = join ',', @unique;
    $dtd_file[$i] = "\\ 'vimxmlentities': [$xmlents],\n";
    last;
  }
}
close $handle;
rename $VIM_DTD_FILE, "$VIM_DTD_FILE.bak";
open OUT, '>', $VIM_DTD_FILE or die $!;
print OUT $_ foreach(@dtd_file);

exit
