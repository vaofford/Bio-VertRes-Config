#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::Common');
}

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::Common->new(
            database            => 'my_database',
            pipeline_short_name => 'new_pipeline',
            module              => 'Bio::Example'
        )
    ),
    'initialise common config'
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
        'log'    => '/nfs/pathnfs01/log/my_database/new_pipeline_logfile.log',
        'root'   => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
        'prefix' => '_',
        'module' => 'Bio::Example'
    },
    'output hash constructed correctly'
);

ok(
    (
        my $obj_non_standard = Bio::VertRes::Config::Pipelines::Common->new(
            database            => 'pathogen_prok_track',
            pipeline_short_name => 'new_pipeline',
            module              => 'Bio::Example'
        )
    ),
    'initialise common config for pipeline with non standard root'
);
is_deeply(
    $obj_non_standard->to_hash,
    {
        'db' => {
            'database' => 'pathogen_prok_track',
            'password' => undef,
            'user'     => 'root',
            'port'     => 3306,
            'host'     => 'localhost'
        },
        'data' => {
            'db' => {
                'database' => 'pathogen_prok_track',
                'password' => undef,
                'user'     => 'root',
                'port'     => 3306,
                'host'     => 'localhost'
            },
            'dont_wait' => 0
        },
        'log'    => '/nfs/pathnfs01/log/prokaryotes/new_pipeline_logfile.log',
        'root'   => '/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines',
        'prefix' => '_',
        'module' => 'Bio::Example'
    },
    'output hash has translated db name in root path'
);

done_testing();
