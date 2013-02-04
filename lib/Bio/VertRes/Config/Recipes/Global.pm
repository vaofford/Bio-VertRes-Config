package Bio::VertRes::Config::Recipes::Global;

# ABSTRACT: Setting up global config files

=head1 SYNOPSIS

Setting up global config files. Done once per database
   use Bio::VertRes::Config::Recipes::Global;
   
   my $obj = Bio::VertRes::Config::Recipes::Global->new( database => 'abc' );
   $obj->create;
   
=cut

use Moose;
use Bio::VertRes::Config::Pipelines::Assembly;
use Bio::VertRes::Config::Pipelines::Import;
use Bio::VertRes::Config::Pipelines::Store;
use Bio::VertRes::Config::MultipleTopLevelFiles;

has 'database'                       => ( is => 'ro', isa => 'Str',  required => 1 );
has 'config_base'                    => ( is => 'ro', isa => 'Str',  default  => '/nfs/pathnfs01/conf' );
has 'overwrite_existing_config_file' => ( is => 'ro', isa => 'Bool', default  => 0 );

sub create {
    my ($self) = @_;

    my @pipeline_configs;

    push(
        @pipeline_configs,
        Bio::VertRes::Config::Pipelines::Assembly->new(
            database                       => $self->database,
            config_base                    => $self->config_base,
            overwrite_existing_config_file => $self->overwrite_existing_config_file
        )
    );
    push(
        @pipeline_configs,
        Bio::VertRes::Config::Pipelines::Import->new(
            database                       => $self->database,
            config_base                    => $self->config_base,
            overwrite_existing_config_file => $self->overwrite_existing_config_file
        )
    );
    push(
        @pipeline_configs,
        Bio::VertRes::Config::Pipelines::Store->new(
            database                       => $self->database,
            config_base                    => $self->config_base,
            overwrite_existing_config_file => $self->overwrite_existing_config_file
        )
    );

    my $top_level = Bio::VertRes::Config::MultipleTopLevelFiles->new(
        database            => $self->database,
        pipeline_configs    => \@pipeline_configs,
        overall_config_base => $self->config_base
    );
    $top_level->update_or_create();

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
