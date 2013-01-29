#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::Store');
}

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::Store->new(
            database => 'my_database',
        )
    ),
    'initialise store config'
);

is_deeply(
    $obj->to_hash,
    {
        'db' => {
            'database' => 'my_database',
            'password' => undef,
            'user'     => 'root',
            'port'     => 3306,
            'host'     => 'localhost'
        },
        'data' => {
            'db' => {
                'database' => 'my_database',
                'password' => undef,
                'user'     => 'root',
                'port'     => 3306,
                'host'     => 'localhost'
            },
            'dont_wait' => 0
        },
        'vrtrack_processed_flags' => {
            'qc'     => 1,
            'stored' => 0
        },
        'root'   => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
        'log'    => '/nfs/pathnfs01/log/my_database/stored_logfile.log',
        'limit'  => 100,
        'module' => 'VertRes::Pipelines::StoreLane',
        'prefix' => '_'
    },
    'output hash constructed correctly'
);

done_testing();
