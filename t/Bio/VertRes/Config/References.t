#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::References');
}

throws_ok(
    sub {
        Bio::VertRes::Config::References->new( reference_lookup_file => 'file_which_doesnt_exist' )
          ->_reference_names_to_files;
    },
    qr/Validation failed/,
    'Initialise file which doesnt exist'
);

ok( ( my $obj = Bio::VertRes::Config::References->new( reference_lookup_file => 't/data/refs.index' ) ),
    'initialise valid object' );

is( $obj->get_reference_location_on_disk('EFG_v2'), '/path/to/EFG_HIJ_v2.fa', 'return location for given reference' );

done_testing();
