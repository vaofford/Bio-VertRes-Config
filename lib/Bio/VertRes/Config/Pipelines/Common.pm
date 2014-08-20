package Bio::VertRes::Config::Pipelines::Common;

# ABSTRACT: A set of attributes common to all pipeline config files

=head1 SYNOPSIS

A set of attributes common to all pipeline config files. It is ment to be extended rather than used on its own.
   use Bio::VertRes::Config::Pipelines::Common;
   extends 'Bio::VertRes::Config::Pipelines::Common';
   
   

=cut

use Moose;
use File::Slurp;
use Bio::VertRes::Config::Types;
use Data::Dumper;
use File::Basename;
use File::Path qw(make_path);
with 'Bio::VertRes::Config::Pipelines::Roles::RootDatabaseLookup';

has 'prefix'              => ( is => 'ro', isa => 'Bio::VertRes::Config::Prefix', default  => '_' );
has 'pipeline_short_name' => ( is => 'ro', isa => 'Str',                          required => 1 );
has 'module'              => ( is => 'ro', isa => 'Str',                          required => 1 );
has 'toplevel_action'     => ( is => 'ro', isa => 'Str',                          required => 1 );
has 'toplevel_admin_approval_required'   => ( is => 'ro', isa => 'Bool', default => 0 );

has 'overwrite_existing_config_file' => ( is => 'ro', isa => 'Bool', default => 0 );

has 'log' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_log' );
has 'log_base'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'log_file_name' => ( is => 'ro', isa => 'Str', default => 'logfile.log' );

has 'config' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_config' );
has 'config_base'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'config_file_name' => ( is => 'ro', isa => 'Str', default  => 'global.conf' );

has 'root' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_root' );
has 'root_base'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'root_pipeline_suffix' => ( is => 'ro', isa => 'Str', default => 'seq-pipelines' );

has 'database' => ( is => 'ro', isa => 'Str',        required => 1 );
has 'host'     => ( is => 'ro', isa => 'Str',        lazy     => 1, builder => '_build_host' );
has 'port'     => ( is => 'ro', isa => 'Int',        lazy     => 1, builder => '_build_port' );
has 'user'     => ( is => 'ro', isa => 'Str',        lazy     => 1, builder => '_build_user' );
has 'password' => ( is => 'ro', isa => 'Maybe[Str]', lazy     => 1, builder => '_build_password' );

has 'database_connect_file' => ( is => 'ro', isa => 'Str', required => 1 );
has '_database_connection_details' =>
  ( is => 'ro', isa => 'Maybe[HashRef]', lazy => 1, builder => '_build__database_connection_details' );
has '_versions' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );

sub _build__versions {
    my %versions = (
        'velvet_0000' => '2.0.0',
        'velvet_1110' => '2.1.0',
        'velvet_1100' => '2.2.0',
        'velvet_1010' => '2.3.0',
        'velvet_0110' => '2.4.0',
        'velvet_1000' => '2.5.0',
        'velvet_0100' => '2.6.0',
        'velvet_0010' => '2.7.0',
        'velvet_0001' => '2.0.1',
        'velvet_1111' => '2.1.1',
        'velvet_1101' => '2.2.1',
        'velvet_1011' => '2.3.1',
        'velvet_0111' => '2.4.1',
        'velvet_1001' => '2.5.1',
        'velvet_0101' => '2.6.1',
        'velvet_0011' => '2.7.1',
        'spades_0000' => '3.0.0',
        'spades_1110' => '3.1.0',
        'spades_1100' => '3.2.0',
        'spades_1010' => '3.3.0',
        'spades_0110' => '3.4.0',
        'spades_1000' => '3.5.0',
        'spades_0100' => '3.6.0',
        'spades_0010' => '3.7.0',
        'spades_0001' => '3.0.1',
        'spades_1111' => '3.1.1',
        'spades_1101' => '3.2.1',
        'spades_1011' => '3.3.1',
        'spades_0111' => '3.4.1',
        'spades_1001' => '3.5.1',
        'spades_0101' => '3.6.1',
        'spades_0011' => '3.7.1',
        'iva_0000'    => '5.0.0',
        'iva_1110'    => '5.1.0',
        'iva_1100'    => '5.2.0',
        'iva_1010'    => '5.3.0',
        'iva_0110'    => '5.4.0',
        'iva_1000'    => '5.5.0',
        'iva_0100'    => '5.6.0',
        'iva_0010'    => '5.7.0',
        'iva_0001'    => '5.0.1',
        'iva_1111'    => '5.1.1',
        'iva_1101'    => '5.2.1',
        'iva_1011'    => '5.3.1',
        'iva_0111'    => '5.4.1',
        'iva_1001'    => '5.5.1',
        'iva_0101'    => '5.6.1',
        'iva_0011'    => '5.7.1'
    );
    return \%versions;
}

sub _build_root {
    my ($self) = @_;
    join( '/', ( $self->root_base, $self->root_database_name, $self->root_pipeline_suffix ) );
}

sub _build_config {
    my ($self) = @_;
    my $conf_file_name = join( '_', ( $self->pipeline_short_name, $self->config_file_name ) );
    join( '/', ( $self->config_base, $self->root_database_name, $self->pipeline_short_name, $conf_file_name ) );
}

sub _build_log {
    my ($self) = @_;
    my $log_file_name = join( '_', ( $self->pipeline_short_name, $self->log_file_name ) );
    join( '/', ( $self->log_base, $self->root_database_name, $log_file_name ) );
}

sub _build_host {
    my ($self) = @_;
    if ( defined( $self->_database_connection_details ) ) {
        return $self->_database_connection_details->{host};
    }
    return $ENV{VRTRACK_HOST} || 'localhost';
}

sub _build_port {
    my ($self) = @_;
    if ( defined( $self->_database_connection_details ) ) {
        return $self->_database_connection_details->{port};
    }
    return $ENV{VRTRACK_PORT} || 3306;
}

sub _build_user {
    my ($self) = @_;
    if ( defined( $self->_database_connection_details ) ) {
        return $self->_database_connection_details->{user};
    }
    return $ENV{VRTRACK_RW_USER} || 'root';
}

sub _build_password {
    my ($self) = @_;
    if ( defined( $self->_database_connection_details ) ) {
        return $self->_database_connection_details->{password};
    }
    return $ENV{VRTRACK_PASSWORD};
}

sub _build__database_connection_details {
    my ($self) = @_;
    my $connection_details;
    if ( -f $self->database_connect_file ) {
        my $text = read_file( $self->database_connect_file );
        $connection_details = eval($text);
    }
    return $connection_details;
}

sub _limits_values_part_of_filename {
    my ($self) = @_;
    my $output_filename = "";
    my @limit_values;
    for my $limit_type (qw(project sample library species lane)) {
        if ( defined $self->limits->{$limit_type} ) {
            my $list_of_limit_values = $self->limits->{$limit_type};
            for my $limit_value ( @{$list_of_limit_values} ) {
                $limit_value =~ s/^\s+|\s+$//g;
                push( @limit_values, $limit_value );

            }
        }
    }
    if ( @limit_values > 0 ) {
        $output_filename = join( '_', @limit_values );
    }
    return $output_filename;
}

sub _filter_characters_truncate_and_add_suffix {
    my ( $self, $output_filename, $suffix ) = @_;
    $output_filename =~ s!\W+!_!g;
    $output_filename =~ s/_$//g;
    $output_filename =~ s/_+/_/g;

    if ( length($output_filename) > 150 ) {
        $output_filename = substr( $output_filename, 0, 146 ) . '_' . int( rand(999) );
    }
    return join( '.', ( $output_filename, $suffix ) );
}

sub create_config_file {
    my ($self) = @_;
    
    my $mode = 0777;
    if ( !( -e $self->config ) ) {
        my ( $config_filename, $directories, $suffix ) = fileparse( $self->config );
        make_path( $directories, {mode => $mode} );
    }

    # If the file exists and you dont want to overwrite existing files, skip it
    return if ( ( -e $self->config ) && $self->overwrite_existing_config_file == 0 );

    # dont print out an extra wrapper variable
    $Data::Dumper::Terse = 1;
    write_file( $self->config, Dumper( $self->to_hash ) );
    chmod $mode, $self->config;
}

sub to_hash {
    my ($self) = @_;

    my %output_hash = (
        root   => $self->root,
        module => $self->module,
        prefix => $self->prefix,
        log    => $self->log,
        db     => {
            database => $self->database,
            host     => $self->host,
            port     => $self->port,
            user     => $self->user,
            password => $self->password,
        },
        data => {
            dont_wait => 0,
            db        => {
                database => $self->database,
                host     => $self->host,
                port     => $self->port,
                user     => $self->user,
                password => $self->password,
            },
        }
    );
    return \%output_hash;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

