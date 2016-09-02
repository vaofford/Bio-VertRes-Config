package Bio::VertRes::Config::CommandLine::BacteriaPermissions;

# ABSTRACT: Create permissions files

=head1 SYNOPSIS

Create permissions files

=cut

use Moose;
use Bio::VertRes::Config::Recipes::Permissions;
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_prok_track' );

sub run {
    my ($self) = @_;

    ($self->type && $self->id  && !$self->help ) or die $self->usage_text;

    my %mapping_parameters = %{$self->mapping_parameters};
    Bio::VertRes::Config::Recipes::Permissions->new( \%mapping_parameters )->create();
    
};

sub usage_text
{
  my ($self) = @_;
  $self->register_and_qc_usage_text;
}

sub register_and_qc_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: bacteria_permissions [options]
Pipeline to run assembly and annotation. Study must be registered and QC'd separately first


# Set permissions for a study
bacteria_permissions -t study -i 1234 

# Set permissions for a single lane
bacteria_permissions -t lane -i 1234_5#6 

# Set permissions for a file of lanes
bacteria_permissions -t file -i file_of_lanes 

# Set permissions for a single species in a study
bacteria_permissions -t study -i 1234  -s "Staphylococcus aureus"

# Set permissions for a study in named database specifying location of configs
bacteria_permissions -t study -i 1234  -d my_database -c /path/to/my/configs

# Set permissions for a study in named database specifying root and log base directories
bacteria_permissions -t study -i 1234  -d my_database -root /path/to/root -log /path/to/log

# Set permissions for a study in named database specifying a file with database connection details 
bacteria_permissions -t study -i 1234  -d my_database -db_file /path/to/connect/file

# This help message
bacteria_permissions -h

USAGE
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;