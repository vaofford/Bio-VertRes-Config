#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::SmaltMapping');
}

my $obj;
ok(
    (
        $obj = Bio::VertRes::Config::Pipelines::SmaltMapping->new(
            database              => 'my_database',
            reference_lookup_file => 't/data/refs.index',
            reference             => 'ABC',
            limits                => { project => ['ABC study( EFG )'] },
        )
    ),
    'initialise smalt mapping config'
);

my $returned_config_hash = $obj->to_hash;
my $prefix               = $returned_config_hash->{prefix};
$returned_config_hash->{prefix} = '_checked_elsewhere_';

is_deeply(
    $returned_config_hash,
    {
      'limits' => {
                              'project' => [
                                             'ABC study( EFG )'
                                           ]
                            },
              'vrtrack_processed_flags' => {
                                             'qc' => 1,
                                             'stored' => 1,
                                             'import' => 1
                                           },
              'db' => {
                        'database' => 'my_database',
                        'password' => undef,
                        'user' => 'root',
                        'port' => 3306,
                        'host' => 'localhost'
                      },
              'data' => {
                          'do_recalibration' => 0,
                          'mark_duplicates' => 1,
                          'get_genome_coverage' => 1,
                          'db' => {
                                    'database' => 'my_database',
                                    'password' => undef,
                                    'user' => 'root',
                                    'port' => 3306,
                                    'host' => 'localhost'
                                  },
                          'dont_wait' => 0,
                          'assembly_name' => 'ABC',
                          'exit_on_errors' => 0,
                          'add_index' => 1,
                          'reference' => '/path/to/ABC.fa',
                          'do_cleanup' => 1,
                          'slx_mapper_exe' => '/software/pathogen/external/apps/usr/local/smalt-0.7.0.1/smalt_x86_64',
                          'slx_mapper' => 'smalt',
                          'ignore_mapped_status' => 1
                        },
              'log' => '/nfs/pathnfs01/log/my_database/mapping__ABC_study_EFG_ABC_smalt.log',
              'root' => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
              'prefix' => '_checked_elsewhere_',
              'module' => 'VertRes::Pipelines::Mapping'
            },
    'Expected smalt base config file'
);

ok(
    (
        $obj = Bio::VertRes::Config::Pipelines::SmaltMapping->new(
            database                 => 'my_database',
            reference_lookup_file    => 't/data/refs.index',
            reference                => 'ABC',
            limits                   => { project => ['ABC study( EFG )'] },
            additional_mapper_params => '-y 0.5  -r 1  -x',
            mapper_index_params      => '-s 4  -k 13'
        )
    ),
    'initialise smalt mapping config with optional parameters for mapper and indexing'
);

$returned_config_hash = $obj->to_hash;
is($returned_config_hash->{data}{additional_mapper_params}, '-y 0.5  -r 1  -x', 'additional parameters present');
is($returned_config_hash->{data}{mapper_index_params}, '-s 4  -k 13', 'additional mapper_index_params present');
is($returned_config_hash->{data}{mapper_index_suffix}, 's4k13', 'suffix generated from mapper index params');

done_testing();
