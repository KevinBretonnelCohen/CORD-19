#!/usr/bin/perl

# Purpose: get counts of lexical items.  The script
# expects a plain text file, and/but does no 
# normalization--I have other scripts that do that.

# Usage:
# lexicalFrequency.pl input_directory > output_file
# output_file will then contain a header line, followed
# by comma-separated words and frequencies.

# Test data is in the directory crafttestfiles.

# Unlike most of my scripts that are intended for 
# later analysis of the output in R, this one outputs
# tab-separated data, rather than comma-separated data.
# That's because I'm sometimes looking at words that end
# with punctuation, which means words that sometimes
# end with commas, which mucks up R when it tries to
# read it in. 

# TODO: need a mechanism to fix the situation where 
# regex reserved characters in an input file cause
# the script to crash.

# mechanism for catching typos
use strict 'vars';

my %frequencies;

my $input_directory = pop(@ARGV);
print STDERR "Input directory: $input_directory\n";

opendir (DIR, $input_directory) || die "Couldn't open input directory $input_directory: $!\n";

my @directory_contents = readdir(DIR);
print STDERR "Directory contents: @directory_contents\n";

# print out the header for R
#print "word,frequency\n";

for (my $i = 0; $i < @directory_contents; $i++) {
    0 && print "File name: $directory_contents[$i]\n";

    # normal file type: .txt
    #if ($directory_contents[$i] =~ /txt$/) {
    # for analyzing brat annotation files
    if ($directory_contents[$i] =~ /ann$/) {
	my $filename = $input_directory . "/" . $directory_contents[$i];

	#open (IN, $directory_contents[$i]) || die "Couldn't open input file $directory_contents[$i]: $!\n";
	open (IN, $filename) || die "Couldn't open input file $directory_contents[$i]: $!\n";

	0 && print "File: $directory_contents[$i]\n";

	# TODO VICIOUS HACK here--explanation below
	if (($directory_contents[$i] =~ /15005800.txt$/o)
	    || ($directory_contents[$i] =~ /17447844.txt$/o)
	    || ($directory_contents[$i] =~ /14723793.txt$/o)
	    || $directory_contents[$i] =~ /17194222.txt$/o
	    || $directory_contents[$i] =~ /16670015.txt$/o
	    || $directory_contents[$i] =~ /16507151.txt$/o
	    || $directory_contents[$i] =~ /14611657.txt$/o
	    || $directory_contents[$i] =~ /17425782.txt$/o) {
	    print STDERR "Skipping file $directory_contents[$i].\n"; 
	    next;
	}

	while (my $line =  <IN>) {
	    0 && print "Contents of line: $line\n";
	    # Perl regular expressions choke on regex reserved characters,
	    # and scientific journal articles definitely contain them 
	    # sometimes, so I'm trying to screen out lines that contain
	    # them.
	    #for (my $i = 0; $i < length($line); $i++) {

	    #}
	    # actually, that was going to be clunkier than I want to deal
	    # with--for the moment, I'm just going to skip any file that
	    # the script is crashing on.
	    # See "TODO Fix VICIOUS HACK here" 
	    # @tokens should contain one whitespace-separated token per
	    # element
	    my @tokens = split(" ", $line);
	    0 && print @tokens;
	    #for (my $j = 0; $j < @tokens; $j++) {
	    foreach my $token (@tokens) {
		0 && print "$token\n";
		$frequencies{$token}++;
		# Chris Roeder, thanks for pointing out that 
		# Perl now has foreach...
	    }
		#1 && print "Token: $tokens[$j]\n";
		#$frequencies{$tokens[$j]}++;
		#print "Added $tokens[$j]\n";
	    #} # close for-loop through this line of content
	} # close while-loop through current file
    }
} # close for-loop through directory

# tell the world what you've learnt

# this clunky line of code sorts by frequencies, rather
# than alphabetically by words.
my @words = sort { $frequencies{$b} <=> $frequencies{$a} } keys(%frequencies);

# produce output
# header for R
print "word\tfrequency\n";

for (my $i = 0; $i < @words; $i++) {
    #print $words[$i] . "," . "$frequencies{$words[$i]}\n";
    print $words[$i] . "\t" . "$frequencies{$words[$i]}\n";
} # close for-loop through the words and their counts
