#!/usr/bin/perl

use strict 'vars';

# input: two files containing lexical frequencies, tab-separated:

# the    7658
# a    5643
# virus   299

# these contain the data as read in from the lexical frequency files
my %corpus01 = ();
my %corpus02 = ();

# this gets added to all counts so that you never have a value of zero
my $smoothing_factor = 100; # Adam liked 100--don't remember why

# sets of files for tests and for the real data
#open(IN1, "/Users/transfer/Dropbox/Scripts-new/cord19.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.10.words.txt") || die "$!\n"; # small file for development only

# test case: all ratios should be 1.0, because you're comparing a corpus against itself
#open(IN1, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";

# test case: almost completely disjunct vocabularies. A and Z are in both corpora and have equal counts, so one or the other should have a ratio of 1.0, depending on whether 01 or 02 is the reference.  The other contents are disjoint, so we should have big numbers for {B, C, D} if file 02 is the reference, and small numbers for {V, W, X, Y} if file 01 is the reference.
open(IN1, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.01.txt") || die "$!\n";
open(IN2, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.02.txt") || die "$!\n";

# READ IN THE DATA
# ...from C1, the corpus of interest
while (my $line = <IN1>) {
    0 && print $line;
    chomp $line;
    if (length($line) < 1) { next; }
    # why am I sometimes having tab-separated input, and sometimes comma-separated?  Aren't these all coming from the same script, i.e. lexicalFrequencies.pl? That outputs tab-separated text... TODO: verify that all of my input data is, indeed, coming from that script...
    my ($word, $frequency) = split("\t", $line);
    #my ($word, $frequency) = split(",", $line);
    0 && print "$word: $frequency\n";
    $corpus01{$word} = $frequency; # + smoothing_factor;
}
close(IN1);

#...from C2, the reference corpus
while (my $line = <IN2>) {
    0 && print $line;
    chomp $line;
    if (length($line) < 1) { next; }
    #my ($word, $frequency) = split(",", $line);
    my ($word, $frequency) = split("\t", $line);
    0 && print "$word: $frequency\n";
    $corpus02{$word} = $frequency; # + smoothing_factor;
}
close(IN2);

# COUNT THE SIZES OF THE CORPORA IN *TOKENS*
# count the sizes of the two corpora so that you can go from counts to frequencies.
# here we have the counts in *tokens*
my $corpus01_tokens = 0;
foreach my $word (keys(%corpus01)) {
    0 && print "$word: frequency = $corpus01{$word}\n";
    $corpus01_tokens = $corpus01_tokens + $corpus01{$word};
    0 && print "Current corpus size: $corpus01_tokens tokens\n";
}
0 && print "Total C1 size: $corpus01_tokens tokens.\n";

my $corpus02_tokens = 0;
foreach my $word (keys(%corpus02)) {
    0 && print "$word: frequency = $corpus02{$word}\n";
    $corpus02_tokens = $corpus02_tokens + $corpus02{$word};
    0 && print "Current corpus 2 size: $corpus02_tokens\n";
}
0 && print "Total C2 size: $corpus02_tokens tokens.\n";

# COUNT THE CORPORA IN *TYPES*
# ...and now in *types*, i.e. the vocabulary sizes:
my $corpus01_vocabulary_size = keys(%corpus01);
my $corpus02_vocabulary_size = keys(%corpus02);
# (note that I don't currently actually use the vocabulary sizes (i.e. number of types), but it's good to have them as a validation check.)
1 && print "Corpus 01 has $corpus01_vocabulary_size types.\n";
1 && print "Corpus 02 has $corpus02_vocabulary_size types.\n";

# get the union of the words in the two corpora
# NO--we just calculate the frequencies for the words that are in the corpus of interest (corpus01)
#my @corpus01_words = keys(%corpus01);
#my @corpus02_words = keys(%corpus02);
#my $corpus01_vocabulary_size = @corpus01_words;
#my $corpus02_vocabulary_size = @corpus02_words;

#my @unioned_words = push(keys(%corpus01), keys(%corpus02)); # I hate it when people write code like this--even when it's me
#my @unioned_words = push(@corpus01_words, @corpus02_words);
#my @unioned_words = @corpus01_words;
#@unioned_words = push(@unioned_words, @corpus02_words);
#push(@unioned_words, @corpus02_words);

# wait, I shouldn't be going through the union of the vocabularies of the two corpora--just the vocabulary of the corpus of interest, right?
#my $unioned_words_vocabulary_size = @unioned_words;

#0 && print "C1 vocabulary: $corpus01_vocabulary_size words C2 vocabulary: $corpus02_vocabulary_size words Union of C1 and C2: $unioned_words_vocabulary_size\n";

# ratio of smoothed relative frequencies in corpus01 to smoothed relative frequencies in corpus02
my %ratios = ();

# DETERMINE THE SMOOTHED RAW FREQUENCIES (i.e. smoothed counts)
# smooth the raw frequencies for both corpora to avoid divide-by-zero errors when you later calculate the ratios of relative frequencies.

my %corpus01_smoothed_frequencies;
my %corpus02_smoothed_frequencies;

#my $c1_raw_freq;
#my $c2_raw_freq;

my $c1_smoothed_frequency;
my $c2_smoothed_frequency;

# see above--you only care about (the words in) the vocabulary of the corpus of interest, now that I think about it more

#foreach my $word (@unioned_words) {
foreach my $word (keys(%corpus01)) {
    1 && print "Before smoothing: $word in C1 raw freq. $corpus01{$word}\n";
    
    # the corpus of interest
    if ($corpus01{$word}) {
	1 && print "$word exists in C1 with unsmoothed frequency $corpus01{$word}\n";
       $c1_smoothed_frequency = $corpus01{$word} + $smoothing_factor;
	1 && print "...and smoothes to $c1_smoothed_frequency\n";
    } else {
	$c1_smoothed_frequency = $smoothing_factor;
	1 && print "$word does not exist in C1. Smoothed to $c1_smoothed_frequency\n"; # is that even possible?? yes, because it's unioned.  But, wait--why do we care, if it's not in the corpus of interest?? So, no: this shouldn't happen, and I should throw an error if it does. TODO
    }
    

    $corpus01_smoothed_frequencies{$word} = $c1_smoothed_frequency;
    1 && print "After smoothing: $word in C1: $c1_smoothed_frequency\n";

    # the reference corpus
    if ($corpus02{$word}) {
	$c2_smoothed_frequency = $corpus02{$word} + $smoothing_factor;
    } else {
	$c2_smoothed_frequency = $smoothing_factor;
	# you should get to this condition a lot--as often as there are words in C1 that aren't in C2
    }

    $corpus02_smoothed_frequencies{$word} = $c2_smoothed_frequency;
    1 && print "$word in C2: $c2_smoothed_frequency\n";
} # close foreach-loop to determine raw frequencies

    # CALCULATE THE RELATIVE FREQUENCIES AND THEIR RATIOS
    # TODO: do the corpus sizes need to be adjusted for the smoothing that we did??? XXX

    # due to the smoothing that we do, there should never be a zero in either the denominator or the numerator

    # YOU ARE HERE. Take a break and then note that you need to have stored the relative frequencies up above.  I think that you need to adjust the corpus sizes for the smoothing, too.
    # note that if you only do this for corpus01, then you only have the relative frequencies for words in corpus01, and *don't* have them for words that are in corpus01 but *not* in corpus02.  TODO: verify that that's what you should be doing.  I guess that to get them for the other corpus, you just reverse the file handle names (IN1 and IN2) when you first read them in.
 #   foreach my $word (@corpus01_words) {
    foreach my $word (keys(%corpus01)) {

      # oh, no wonder these were all the same---they all got whatever the most recently-calculated value was for $c1 or $c2_relative_freq!! 
      #my $c1_relative_freq = $c1_raw_freq / $corpus01_size;
      #my $c2_relative_freq = $c2_raw_freq / $corpus02_size;
	
      #1 && print "<$word> C1 relative: $c1_relative_freq C2 relative: $c2_relative_freq\n";
	
      # haha, dumbass Kevin--these values never changed, and that's why every word had the same ratio!
      #my $ratio = $c1_relative_freq / $c2_relative_freq;

      #1 && print "<$word> ratio: $ratio\n";
      
      # you did it again, asshole!	
      #my $ratio = $c1_smoothed_frequency / $c2_smoothed_frequency;
      my $ratio = $corpus01_smoothed_frequencies{$word} / $corpus02_smoothed_frequencies{$word};	
      1 && print "<$word> C1 smoothed: $corpus01_smoothed_frequencies{$word} C2 smoothed: $corpus02_smoothed_frequencies{$word} ratio: $ratio\n";
	
      $ratios{$word} = $ratio;

    } # close foreach-loop to calculate relative frequencies
 
# TODO: validate that the number of words for which you now have ratios is equal to the number of words in C1 (the corpus of interest)
# ...oh, OK--now I can use the count of types that I got a long time ago
my $number_of_words_with_ratios = keys(%ratios);
unless ($number_of_words_with_ratios == $corpus01_vocabulary_size) {
    die "Number of words with ratios is $number_of_words_with_ratios. Number of words in Corpus 01 is $corpus01_vocabulary_size. These should be equal!\n";
}

# PRODUCE OUTPUT: words in corpus01 sorted by relative C1:C2 ratio
#my @ordered_by_ratio = sort { $b <=> $a } keys(%ratios);
my @ordered_by_ratio = sort { $ratios{$b} <=> $ratios{$a} } keys(%ratios);

foreach my $word (@ordered_by_ratio) {
    print "$word\t$ratios{$word}\n";
}

