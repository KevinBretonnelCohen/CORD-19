#!/usr/bin/perl

# plug in a regex to count anything you want. Takes input from a pipe or from a file.

# output is tab-separated.

use strict 'vars';

my $DEBUG = 0; # set to 1 for helpful debugging output

# this assumes input from a file that is read in--see below for input from a pipe
#my $infile = pop(@ARGV);
#opendir(
#open (IN, $infile) || die "Couldn't open infile: $!\n";

my %counts = ();

#while (my $line = <IN>) {
# this assumes input from a pipe...
while (my $line = <>) {
    my $counter = 0;
#    while ($line =~ /(open question|is not known|unknown)/goi) {
    #while ($line =~ /(\,|\()/goi) {

    # from Mayla's cues
#    while ($line =~ /(additional research
                     #|additional studies
                     #|appears to be
                     #|open question
                     #|is not known
                     #|unknown)/goix) {
#    while ($line =~ /(additional research|additional studies|appears to be|open question|is not known|is needed|are needed|alternative hypotheis|appear to be|appears to be|appeared to be|appearing to be|is needed|are needed|is warranted|are warranted|calls into question|called into question|calling into question|unknown|controversial|controversy|controversies|could not be assesssed|could not be determined|cannot be assessed|cannot be determined|debate|debates|debated|debating|not understood|further investigation|further research|further testing|further tests|further work|little is known|not been observed|not understood|not well understood|not been determined|not yet been determined|not been examined|not yet been examined|not been studied|not yet been studied|remains elusive|remains limited|remains unexplored|remains relatively unexplored|remains unstudied|remains relatively unstudied|remains limited|warrants|merits|deserves)/goi) {

# "syntactic" punctuation marks
#while ($line =~ /(,|\.|;|:|\(|\))/goi) {
#while ($line =~ /(and|or|but|nor|neither)/goi) {
# subordinators
#while ($line =~ /(because|since|as|when|that)/goi) {
# wh-pronouns
while ($line =~ /(who|whose|whom|which)/goi) {

	$DEBUG && print "Matched: <$1>\n";
	my $match = lc($1);
	$counter++;	
	$counts{$match}++;
        $DEBUG && print "Hits: $counter\n";
    } # close while-loop through line
} # close while-loop through file

my $total_match_types = 0;
my $total_match_tokens = 0;
foreach my $match (sort (keys(%counts))) {
    $total_match_types++;
    $total_match_tokens += $counts{$match};
    print "$match\t$counts{$match}\n";
}
print "TOTAL MATCH TYPES\t$total_match_types\n";
print "TOTAL MATCH TOKENS\t$total_match_tokens\n";
