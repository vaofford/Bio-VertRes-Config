#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::Assembly');
}

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::Assembly->new(
            database => 'my_database',
        )
    ),
    'initialise assembly config'
);

is_deeply(
    $obj->to_hash,
    {
        'max_failures' => 6,
        'db'           => {
            'database' => 'my_database',
            'password' => undef,
            'user'     => 'root',
            'port'     => 3306,
            'host'     => 'localhost'
        },
        'data' => {
            'genome_size' => 10000000,
            'db'          => {
                'database' => 'my_database',
                'password' => undef,
                'user'     => 'root',
                'port'     => 3306,
                'host'     => 'localhost'
            },
            'assembler_exec'    => '/software/pathogen/external/apps/usr/bin/velvet',
            'dont_wait'         => 0,
            'assembler'         => 'velvet',
            'seq_pipeline_root' => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
            'tmp_directory'     => '/lustre/scratch108/pathogen/pathpipe/tmp',
            'max_threads'       => 1,
            'optimiser_exec'    => '/software/pathogen/external/apps/usr/bin/VelvetOptimiser.pl'
        },
        'max_lanes_to_search'     => 200,
        'vrtrack_processed_flags' => {
            'assembled'          => 0,
            'rna_seq_expression' => 0,
            'stored'             => 1
        },
        'root'   => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
        'log'    => '/nfs/pathnfs01/log/my_database/stored_logfile.log',
        'limit'  => 100,
        'module' => 'VertRes::Pipelines::Assembly',
        'prefix' => '_assembly_'
    },
    'output hash constructed correctly'
);

done_testing();
