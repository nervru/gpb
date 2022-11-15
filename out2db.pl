#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 1;

use DBI;


my $dbh = DBI->connect(
    'DBI:mysql:database=gpb;host=localhost', 'gpb', 'passwd',
    { RaiseError => 1 },
);

my $out = $ARGV[0] || 'out';
my $OUT;

my $c = 1;

open OUT, $out or die "Can't open out file\n";
while( <OUT> ) {
    chomp;
    my @line = split / /, $_, 5;

    my $ts     = "$line[0] $line[1]";
    my $int_id = $line[2];

    # log message can be without int_id
    undef $int_id
       unless $int_id =~ /^[0-9a-zA-Z]{6}-[0-9a-zA-Z]{6}-[0-9a-zA-Z]{2}$/;

    if( $line[3] eq '<=' ) {

        my $id = '';
        $id = $1 if $line[4] =~ /\sid=([^\s]+)/;

        $dbh->do(q(
            INSERT INTO message( created, id, int_id, str, status, log_id )
            VALUES ( ?,?,?,?,?,? )
            ), undef,
            $ts,
            $id || 'empty ID for '. $int_id,
            $int_id,
            $line[4] || '',
            $id ? 1 : 0,
            $c,
        );
    }
    else {

        # do not include int_id in str;
        # log message can consist one word;
        my $str = join( ' ', $line[3] || (), $line[4] || () );

        my $address;
        # address may be like NAME <E-MAIL>
        $address = $1 if $line[4] && $line[4] =~ /([^\s<]+?@[^\s>:]+)/;

        $dbh->do(q(
            INSERT INTO log( created, int_id, str, address, log_id )
            VALUES ( ?,?,?,?,? )
            ), undef,
            $ts,
            $int_id,
            $str,
            $address,
            $c,
        );
    }

    $c ++;
}
close OUT;


exit;
