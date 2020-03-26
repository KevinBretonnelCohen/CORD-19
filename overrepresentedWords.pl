#!/usr/bin/perl

use strict 'vars';

my %corpus01 = ();
my %corpus02 = ();

my $smoothing_factor = 100; # Adam liked 100--don't remember why

open(IN1, "/Users/transfer/Dropbox/Scripts-new/cord19.lexical.frequencies.txt") || die "$!\n";
open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.lexical.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.10.words.txt") || die "$!\n";

# test case: all ratios should be 1.0, because you're comparing a corpus against itself
#open(IN1, "/Users/transfer/Dropbox/Scripts-new/craft.word.frequencies.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/craft.word.frequencies.txt") || die "$!\n";

# test case: completely disjunct vocabularies, so big numbers for A-E and small numbers for V-Z
#open(IN1, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.01.txt") || die "$!\n";
#open(IN2, "/Users/transfer/Dropbox/Scripts-new/test.overrepresented.02.txt") || die "$!\n";

while (my $line = <IN1>) {
    0 && print $line;
    chomp $line;
    if (length($line) < 1) { next; }
    # why am I sometimes having tab-separated input, and sometimes comma-separated?  Aren't these all coming from the same script, i.e. lexicalFrequencies.pl? That outputs tab-separated text... TODO: verify that all of my input data is, indeed, coming from that script...
    #my ($word, $frequency) = split("\t", $line);
    my ($word, $frequency) = split(",", $line);
    0 && print "$word: $frequency\n";
    $corpus01{$word} = $frequency; # + smoothing_factor;
}
close(IN1);

while (my $line = <IN2>) {
    0 && print $line;
    chomp $line;
    if (length($line) < 1) { next; }
    my ($word, $frequency) = split(",", $line);
    0 && print "$word: $frequency\n";
    $corpus02{$word} = $frequency; # + smoothing_factor;
}
close(IN2);

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

foreach my $word (@unioned_words) {

    my $c1_raw_freq;
    if ($corpus01{$word}) {
       $c1_raw_freq = $corpus01{$word} + $smoothing_factor;
    } else {
	$c1_raw_freq = $smoothing_factor;
    }
    my $c2_raw_freq;
    if ($corpus02{$word}) {
	$c2_raw_freq = $corpus02{$word} + $smoothing_factor;
    } else {
	$c2_raw_freq = $smoothing_factor;
    }

    # TODO: do the corpus sizes need to be adjusted for the smoothing that we did??? XXX

    # due to the smoothing that we did, there should never be a zero in either the denominator or the numerator
    my $c1_relative_freq = $c1_raw_freq / $corpus01_size;
    my $c2_relative_freq = $c2_raw_freq / $corpus02_size;

    0 && print "<$word> C1 relative: $c1_relative_freq C2 relative: $c2_relative_freq\n";

    my $ratio = $c1_relative_freq / $c2_relative_freq;
    0 && print "<$word> ratio: $ratio\n";
    $ratios{$word} = $ratio;
} # close foreach-loop through set of all words in both corpora

#my @ordered_by_ratio = sort { $b <=> $a } keys(%ratios);
my @ordered_by_ratio = sort { $ratios{$b} <=> $ratios{$a} } keys(%ratios);

foreach my $word (@ordered_by_ratio) {
    print "$word,$ratios{$word}\n";
}
