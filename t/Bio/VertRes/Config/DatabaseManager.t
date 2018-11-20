#!/usr/bin/env perl
use strict;
use warnings;
use Test::Exception;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::DatabaseManager');
}

$ENV{VERTRES_DB_CONFIG} = '';
throws_ok { Bio::VertRes::Config::DatabaseManager->new( database => 'some_database') } 
  qr/Couldnt find database connect file/,
  'throws error with no database connect file or environment variable';

throws_ok { Bio::VertRes::Config::DatabaseManager->new( database => 'some_database', database_connect_file=> 't/data/no_database_connection_details') } 
  qr/Couldnt find database connect file/,
  'throws error with no database connect file or environment variable';

ok( (Bio::VertRes::Config::DatabaseManager->new( database => 'some_database', database_connect_file=> 't/data/database_connection_details' ) ),
  'initialise object with valid user-defined database connect file' );

$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';
ok( (my $obj = Bio::VertRes::Config::DatabaseManager->new( database => 'some_database' ) ),
    'initialise object using VERTRES_DB_CONFIG evironment variable' );

my $expected_database_connection_details = {
  'password' => 'some_password',
  'mlwarehouse_password' => 'ml_password',
  'mlwarehouse_user' => 'ml_user',
  'user' => 'some_user',
  'mlwarehouse_host' => 'ml_hostname',
  'mlwarehouse_port' => 5678,
  'host' => 'some_hostname',
  'port' => 1234
};

is_deeply($obj->build_database_connection_details, $expected_database_connection_details, 'got expected database connection details');

done_testing();
