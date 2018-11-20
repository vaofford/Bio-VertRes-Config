#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use File::Slurper qw[write_text read_text];
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Recipes::Global');
}

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();
$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';

# Create a few config objects for testing

ok((my $obj = Bio::VertRes::Config::Recipes::Global->new( database => 'my_database', config_base => $destination_directory )), 'initalise creating files');
ok(($obj->create), 'Create all the config files and toplevel files');

ok(-e $destination_directory.'/my_database/my_database_import_cram_pipeline.conf', 'import toplevel file');

my $text = read_text( $destination_directory.'/my_database/my_database_import_cram_pipeline.conf' );
chomp($text);
is($text, "__VRTrack_Import_cram__ $destination_directory/my_database/import_cram/import_cram_global.conf", 'content of import toplevel file as expected');
ok((-e "$destination_directory/my_database/import_cram/import_cram_global.conf"), 'import config file exists');


done_testing();
