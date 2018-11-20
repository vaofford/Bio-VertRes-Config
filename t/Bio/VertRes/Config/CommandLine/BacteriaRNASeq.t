#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use Moose;
use Data::Dumper;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::CommandLine::BacteriaRnaSeqExpression');
}

$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

ok(my $obj = Bio::VertRes::Config::CommandLine::BacteriaRnaSeqExpression->new(
  args => [], 
  script_name => '',
	config_base => $destination_directory,
	log_base => $destination_directory,
), 'initialise dummy object');
is( $obj->protocol, 'StandardProtocol', 'check protocol');


done_testing();
