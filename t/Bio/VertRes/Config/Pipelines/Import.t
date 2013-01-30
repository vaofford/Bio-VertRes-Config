#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::Import');
}

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::Import->new(
            database => 'my_database',
        )
    ),
    'initialise import config'
);
is($obj->toplevel_action, '__VRTrack_Import__');
is_deeply(
    $obj->to_hash,
    {
        'mpsa_limit' => 500,
        'db'         => {
            'database' => 'my_database',
            'password' => undef,
            'user'     => 'root',
            'port'     => 3306,
            'host'     => 'localhost'
        },
        'data' => {
            'exit_on_errors' => 0,
            'db'             => {
                'database' => 'my_database',
                'password' => undef,
                'user'     => 'root',
                'port'     => 3306,
                'host'     => 'localhost'
            },
            'dont_wait' => 0
        },
        'log'    => '/nfs/pathnfs01/log/my_database/import_logfile.log',
        'root'   => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
        'prefix' => '_',
        'module' => 'VertRes::Pipelines::Import_iRODS_fastq'
    },
    'output hash constructed correctly'
);

done_testing();

