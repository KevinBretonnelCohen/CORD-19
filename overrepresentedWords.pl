#!/usr/bin/perl

use strict 'vars';

my %corpus01 = ();
my %corpus02 = ();

my $smoothing_factor = 100; # Adam liked 100--don't remember why

#open(IN1, "/Users/transfer/Dropbox/Scripts-new/cord19.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.10.words.txt") || die "$!\n"; # small file for development only

# test case: all ratios should be 1.0, because you're comparing a corpus against itself
#open(IN1, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";

# test case: almost completely disjunct vocabularies. A and Z are in both corpora and have equal counts, so one or the other should have a ratio of 1.0, depending on whether 01 or 02 is the reference.  The other contents are disjoint, so we should have big numbers for {B, C, D} if file 02 is the reference, and small numbers for {V, W, X, Y} if file 01 is the reference.
open(IN1, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.01.txt") || die "$!\n";
open(IN2, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.02.txt") || die "$!\n";

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

# count the sizes of the two corpora so that you can go from counts to frequencies
my $corpus01_size = 0;
foreach my $word (keys(%corpus01)) {
    0 && print "$word: frequency = $corpus01{$word}\n";
    $corpus01_size = $corpus01_size + $corpus01{$word};
    0 && print "Current corpus size: $corpus01_size\n";
}
0 && print "Corpus 1 size: $corpus01_size\n";

my $corpus02_size = 0;
foreach my $word (keys(%corpus02)) {
    0 && print "$word: frequency = $corpus02{$word}\n";
    $corpus02_size = $corpus02_size + $corpus02{$word};
    0 && print "Current corpus 2 size: $corpus02_size\n";
}
0 && print "Corpus 2 size: $corpus02_size\n";

# get the union of the words in the two corpora
my @corpus01_words = keys(%corpus01);
my @corpus02_words = keys(%corpus02);
my $corpus01_vocabulary_size = @corpus01_words;
my $corpus02_vocabulary_size = @corpus02_words;

#my @unioned_words = push(keys(%corpus01), keys(%corpus02)); # I hate it when people write code like this--even when it's me
#my @unioned_words = push(@corpus01_words, @corpus02_words);
my @unioned_words = @corpus01_words;
#@unioned_words = push(@unioned_words, @corpus02_words);
push(@unioned_words, @corpus02_words);

my $unioned_words_vocabulary_size = @unioned_words;

0 && print "C1 vocabulary: $corpus01_vocabulary_size words C2 vocabulary: $corpus02_vocabulary_size words Union of C1 and C2: $unioned_words_vocabulary_size\n";

my %ratios = ();

# DETERMINE THE RAW FREQUENCIES (i.e. smoothed counts)
# smooth the raw frequencies for both corpora to avoid divide-by-zero errors when you later calculate the relative frequencies.

my %corpus01_raw_frequencies;
my %corpus02_raw_frequencies;

my $c1_raw_freq;
my $c2_raw_freq;

foreach my $word (@unioned_words) {

    # the corpus of interest
    if ($corpus01{$word}) {
       $c1_raw_freq = $corpus01{$word} + $smoothing_factor;
    } else {
	$c1_raw_freq = $smoothing_factor;
    }

    $corpus01_raw_frequencies{$word} = $c1_raw_freq;

    # the reference corpus
    if ($corpus02{$word}) {
	$c2_raw_freq = $corpus02{$word} + $smoothing_factor;
    } else {
	$c2_raw_freq = $smoothing_factor;
    }

    $corpus02_raw_frequencies{$word} = $c2_raw_freq;

} # close foreach-loop to determine raw frequencies

    # CALCULATE THE RELATIVE FREQUENCIES
    # TODO: do the corpus sizes need to be adjusted for the smoothing that we did??? XXX

    # due to the smoothing that we do, there should never be a zero in either the denominator or the numerator

    # YOU ARE HERE. Take a break and then note that you need to have stored the relative frequencies up above.  I think that you need to adjust the corpus sizes for the smoothing, too.
    # note that if you only do this for corpus01, then you only have the relative frequencies for words in corpus01, and *don't* have them for words that are in corpus01 but *not* in corpus02.  TODO: verify that that's what you should be doing.  I guess that to get them for the other corpus, you just reverse the file handle names (IN1 and IN2) when you first read them in.
    foreach my $word (@corpus01_words) {
      my $c1_relative_freq = $c1_raw_freq / $corpus01_size;
      my $c2_relative_freq = $c2_raw_freq / $corpus02_size;

      0 && print "<$word> C1 relative: $c1_relative_freq C2 relative: $c2_relative_freq\n";

      my $ratio = $c1_relative_freq / $c2_relative_freq;
      0 && print "<$word> ratio: $ratio\n";

      $ratios{$word} = $ratio;

    } # close foreach-loop to calculate relative frequencies
 
#my @ordered_by_ratio = sort { $b <=> $a } keys(%ratios);
my @ordered_by_ratio = sort { $ratios{$b} <=> $ratios{$a} } keys(%ratios);

foreach my $word (@ordered_by_ratio) {
    print "$word,$ratios{$word}\n";
}

