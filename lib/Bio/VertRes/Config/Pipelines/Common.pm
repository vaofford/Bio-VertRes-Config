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

has 'prefix'               => ( is => 'ro', isa => 'Bio::VertRes::Config::Prefix', default  => '_' );
has 'pipeline_short_name'  => ( is => 'ro', isa => 'Str',                          required => 1 );
has 'module'               => ( is => 'ro', isa => 'Str',                          required => 1 );
has 'toplevel_action'      => ( is => 'ro', isa => 'Str',                          required => 1 );
                           
has 'log'                  => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_log' );
has 'log_base'             => ( is => 'ro', isa => 'Str', default => '/nfs/pathnfs01/log' );
has 'log_file_name'        => ( is => 'ro', isa => 'Str', default => 'logfile.log' );
                           
has 'config'               => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_config' );
has 'config_base'          => ( is => 'ro', isa => 'Str', default => '/nfs/pathnfs01/conf' );
has 'config_file_name'     => ( is => 'ro', isa => 'Str', default => 'global.conf' );

has 'root'                 => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_root' );
has 'root_base'            => ( is => 'ro', isa => 'Str', default => '/lustre/scratch108/pathogen/pathpipe' );
has 'root_pipeline_suffix' => ( is => 'ro', isa => 'Str', default => 'seq-pipelines' );

has 'database'             => ( is => 'ro', isa => 'Str',        required => 1 );
has 'host'                 => ( is => 'ro', isa => 'Str',        lazy     => 1, builder => '_build_host' );
has 'port'                 => ( is => 'ro', isa => 'Int',        lazy     => 1, builder => '_build_port' );
has 'user'                 => ( is => 'ro', isa => 'Str',        lazy     => 1, builder => '_build_user' );
has 'password'             => ( is => 'ro', isa => 'Maybe[Str]', lazy     => 1, builder => '_build_password' );

sub _build_root {
    my ($self) = @_;
    join( '/', ( $self->root_base, $self->root_database_name, $self->root_pipeline_suffix ) );
}

sub _build_config {
    my ($self) = @_;
    my $conf_file_name = join( '_', ( $self->pipeline_short_name, $self->config_file_name ) );
    join( '/', ( $self->config_base, $self->root_database_name, $self->pipeline_short_name,  $conf_file_name ) );
}

sub _build_log {
    my ($self) = @_;
    my $log_file_name = join( '_', ( $self->pipeline_short_name, $self->log_file_name ) );
    join( '/', ( $self->log_base, $self->root_database_name, $log_file_name ) );
}

sub _build_host {
    my ($self) = @_;
    $ENV{VRTRACK_HOST} || 'localhost';
}

sub _build_port {
    my ($self) = @_;
    $ENV{VRTRACK_PORT} || 3306;
}

sub _build_user {
    my ($self) = @_;
    $ENV{VRTRACK_RW_USER} || 'root';
}

sub _build_password {
    my ($self) = @_;
    $ENV{VRTRACK_PASSWORD};
}

sub create_config_file
{
   my ($self) = @_;
   
   if(!(-e $self->config))
   {
     my($config_filename, $directories, $suffix) = fileparse($self->config);
     make_path($directories);
   }
   # dont print out an extra wrapper variable
   $Data::Dumper::Terse = 1;
   write_file( $self->config, Dumper( $self->to_hash));
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

__PACKAGE__->meta->make_immutable;
no Moose;
1;

