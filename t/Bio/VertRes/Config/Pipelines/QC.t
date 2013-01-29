#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::QC');
}

my $obj;
ok(
    (
        $obj = Bio::VertRes::Config::Pipelines::QC->new(
            database => 'my_database',
            reference_lookup_file => 't/data/refs.index',
            reference => 'ABC',
            limits => { project => ['ABC study( EFG )']}
        )
    ),
    'initialise qc config'
);

is_deeply(
    $obj->to_hash,
    {
              'limits' => {
                            'project' => [
                                           'ABC\ study\(\ EFG\ \)'
                                         ]
                          },
              'max_failures' => 3,
              'db' => {
                        'database' => 'my_database',
                        'password' => undef,
                        'user' => 'root',
                        'port' => 3306,
                        'host' => 'localhost'
                      },
              'data' => {
                          'chr_regex' => '.*',
                          'db' => {
                                    'database' => 'my_database',
                                    'password' => undef,
                                    'user' => 'root',
                                    'port' => 3306,
                                    'host' => 'localhost'
                                  },
                          'glf' => '/software/vertres/bin-external/glf',
                          'mapper' => 'bwa',
                          'do_samtools_rmdup' => 1,
                          'fai_ref' => '/path/to/ABC.fa.fai',
                          'gtype_confidence' => '1.2',
                          'bwa_ref' => '/path/to/ABC.fa',
                          'assembly' => 'ABC',
                          'skip_genotype' => 1,
                          'dont_wait' => 0,
                          'mapviewdepth' => '/software/pathogen/external/apps/usr/bin/bindepth',
                          'stats_ref' => '/path/to/ABC.fa.refstats',
                          'exit_on_errors' => 0,
                          'bwa_exec' => '/software/pathogen/external/apps/usr/bin/bwa',
                          'samtools' => '/software/pathogen/external/apps/usr/bin/samtools',
                          'adapters' => '/lustre/scratch108/pathogen/pathpipe/usr/share/solexa-adapters.fasta',
                          'fa_ref' => '/path/to/ABC.fa',
                          'snps' => '/lustre/scratch108/pathogen/pathpipe/usr/share/mousehapmap.snps.bin'
                        },
              'log' => '/nfs/pathnfs01/log/my_database/qc__ABC_study_EFG.log',
              'root' => '/lustre/scratch108/pathogen/pathpipe/my_database/seq-pipelines',
              'prefix' => '_',
              'module' => 'VertRes::Pipelines::TrackQC_Fastq'
            },
    'output hash constructed correctly'
);

done_testing();
