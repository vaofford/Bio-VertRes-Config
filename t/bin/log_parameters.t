#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;


BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
}

opendir( my $dh, './bin' ) || die "can't bin directory: $!";
my @available_scripts = grep { /^[^\.]/ } readdir($dh);
closedir $dh;

for my $script_name (  @available_scripts ) {
    my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
    my $destination_directory = $destination_directory_obj->dirname();

    system("./bin/$script_name --config_base $destination_directory --log_base $destination_directory >/dev/null 2>&1");
    ok( -e $destination_directory . '/command_line.log', "log file has been created for $script_name" );
    open(my $fh, $destination_directory . '/command_line.log');
    my $line = <$fh>;
    ok(($line =~ /^[\w]+[\s]+[\w]+[\s]+[\d]+[\s]+[\d]+:[\d]+:[\d]+[\s]+[\d]+[\s]+[\w\d]+[\s]+\.\/bin\/$script_name --config_base $destination_directory --log_base $destination_directory$/), 'correct format of log file' );

}

done_testing();

