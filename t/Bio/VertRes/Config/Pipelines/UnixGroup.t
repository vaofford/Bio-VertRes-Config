#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Pipelines::Roles::UnixGroup');
    use_ok('Bio::VertRes::Config::Pipelines::Roles::UnixGroup::Test');
}
my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();
$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';

ok(
    (
        my $obj = Bio::VertRes::Config::Pipelines::Roles::UnixGroup::Test->new(
            database    => 'my_database',
            limits      => {project => ['Abc def (ghi123)']},
            root_base   => '/path/to/root',
            log_base    => '/path/to/log',
            config_base => $destination_directory
        )
    ),
    'initialise config'
);

# Test unix group
$obj->data_access_groups( ['A'] );
is(
    $obj->unix_group,
    'pathogen',
    'default unix group when only data access groups found'
);

$obj->data_access_groups( [] );
$obj->admin_groups( ['A'] );
is(
    $obj->unix_group,
    'pathogen',
    'default unix group when only admin groups found'
);

$obj->data_access_groups( ['A'] );
$obj->admin_groups( ['A'] );
is(
    $obj->_build__unix_group,
    'A',
    'set unix group when intersect of single values'
);

$obj->data_access_groups( ['A','B'] );
$obj->admin_groups( ['B','C'] );
is(
    $obj->_build__unix_group,
    'B',
    'define unix group when intersect of multiple values'
);

$obj->data_access_groups( ['C','D'] );
$obj->admin_groups( ['D','C'] );
is(
    $obj->_build__unix_group,
    'C',
    'define unix group as first when multiple intersect values'
);


done_testing();