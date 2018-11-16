#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::ImportCram');
}

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();
$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::ImportCram->new(
            database    => 'my_database',
            root_base   => '/path/to/root',
            log_base    => '/path/to/log',
            config_base => $destination_directory
        )
    ),
    'initialise import_cram config'
);
is($obj->toplevel_action, '__VRTrack_Import_cram__');
is_deeply(
    $obj->to_hash,
    {
              'db' => {
                        'database' => 'my_database',
                        'password' => 'some_password',
                        'user' => 'some_user',
                        'port' => 1234,
                        'host' => 'some_hostname'
                      },
              'data' => {
                          'samtools_exec' => '/software/pathogen/external/apps/usr/bin/samtools-1.1.30',
                          'db' => {
                                    'database' => 'my_database',
                                    'password' => 'some_password',
                                    'user' => 'some_user',
                                    'port' => 1234,
                                    'host' => 'some_hostname'
                                  },
                          'dont_wait' => 0,
                          'cramtools_jar' => '/software/pathogen/external/apps/usr/share/java/cramtools-2.1.jar',
                          'cramtools_java' => '/software/jdk1.8.0_11/bin/java'
                        },
              'log' => '/path/to/log/my_database/import_cram_logfile.log',
              'root' => '/path/to/root/my_database/seq-pipelines',
              'prefix' => '_',
			  'umask' => 23,
			  'octal_permissions' => 488,
			  'unix_group' => 'pathogen',
              'module' => 'VertRes::Pipelines::Import_iRODS_cram'
            },
    'output hash constructed correctly'
);




is(
    $obj->config,
    $destination_directory . '/my_database/import_cram/import_cram_global.conf',
    'config file in expected format'
);
ok( $obj->create_config_file, 'Can run the create config file method' );
ok( ( -e $obj->config ), 'Config file exists' );



done_testing();

