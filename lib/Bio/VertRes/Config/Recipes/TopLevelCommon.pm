package Bio::VertRes::Config::Recipes::TopLevelCommon;

# ABSTRACT: Common base for recipes for top level files

=head1 SYNOPSIS

Common base for recipes
   use Bio::VertRes::Config::Recipes::TopLevelCommon;
   extends 'Bio::VertRes::Config::Recipes::TopLevelCommon';

=cut

use Moose;
use Bio::VertRes::Config::MultipleTopLevelFiles;

has 'database'                       => ( is => 'rw', isa => 'Str',  required => 1 );
has 'database_connect_file'          => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/config/database_connection_details' );
has 'config_base'                    => ( is => 'ro', isa => 'Str',  default  => '/nfs/pathnfs05/conf' );
has 'root_base'                      => ( is => 'ro', isa => 'Str',  default  => '/lustre/scratch118/infgen/pathogen/pathpipe' );
has 'log_base'                       => ( is => 'ro', isa => 'Str',  default  => '/nfs/pathnfs05/log' );
has 'overwrite_existing_config_file' => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'limits'                         => ( is => 'ro', isa => 'HashRef', default => sub { {} });

has '_pipeline_configs'              => ( is => 'ro', isa => 'ArrayRef', default => sub { [] });

sub create {
    my ($self) = @_;

    my $top_level = Bio::VertRes::Config::MultipleTopLevelFiles->new(
        database            => $self->database,
        pipeline_configs    => $self->_pipeline_configs,
        config_base => $self->config_base
    );
    $top_level->update_or_create();

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
