package Bio::VertRes::Config::Recipes::Permissions;
# ABSTRACT: Create the permisisons files only, so no reference required

=head1 SYNOPSIS

Register and QC a study
   use Bio::VertRes::Config::Recipes::Permissions;

   my $obj = Bio::VertRes::Config::Recipes::Permissions->new(
     database => 'abc',
     limits => {project => ['Study ABC']}
     );
   $obj->create;

=cut

use Moose;
use Bio::VertRes::Config::Pipelines::Permissions;
extends 'Bio::VertRes::Config::Recipes::Common';

override '_pipeline_configs' => sub {
    my ($self) = @_;
    my @pipeline_configs;

    if ( defined $self->limits->{'project'} )
    {
        push(
            @pipeline_configs,
            Bio::VertRes::Config::Pipelines::Permissions->new(
                database                       => $self->database,
                database_connect_file          => $self->database_connect_file,
                config_base                    => $self->config_base,
                root_base                      => $self->root_base,
                log_base                       => $self->log_base,
                overwrite_existing_config_file => $self->overwrite_existing_config_file,
                limits                         => $self->limits
            )
        );
    }
    
    return \@pipeline_configs;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

