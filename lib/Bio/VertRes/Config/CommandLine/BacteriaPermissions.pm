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
Usage: bacteria_permissions -t <ID type> -i <ID> [options]
Pipeline to set file permissions.

Required: 
  -t            STR Type (study/lane/file)
  -i            STR Study name, study ID, lane, file of lanes
      
Options:
  -s            STR Limit to a single species name (e.g. 'Staphylococcus aureus')
  -d            STR Specify a database [pathogen_prok_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details
  -h            Print this message and exit

USAGE
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;
