package Bio::VertRes::Config::CommandLine::BacteriaAssemblySingleCell;

# ABSTRACT: Create assembly and annotation files

=head1 SYNOPSIS

Create assembly and annotation files, but QC must have been run first, avoids the need for a reference

=cut

use Moose;
use Bio::VertRes::Config::Recipes::BacteriaAssemblySingleCell;
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_prok_track' );

sub run {
    my ($self) = @_;

    ($self->type && $self->id  && !$self->help ) or die $self->usage_text;

    my %mapping_parameters = %{$self->mapping_parameters};
    Bio::VertRes::Config::Recipes::BacteriaAssemblySingleCell->new( \%mapping_parameters )->create();

    $self->retrieving_results_text;
};

sub retrieving_results_text {
    my ($self) = @_;
    print "Your request was SUCCESSFUL\n\n";
    print "NOTE - If you are uncertain that your request was successful, please do NOT run the command again. Instead, please direct any queries to path-help\@sanger.ac.uk.\n\n";
    print "If you use the results of this pipeline, please acknowledge the pathogen informatics team and include the appropriate citations for the pipeline. For more information on how to cite this pipeline, please see:\n";
    print "http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pipelines_-_Methods\n";
}

sub usage_text
{
  my ($self) = @_;
  $self->register_and_qc_usage_text;
}

sub register_and_qc_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: bacteria_assembly_single_cell -t <ID type> -i <ID> [options]
Pipeline to run assembly and annotation on single cell data.
Study must be registered and QC'd separately first

Required:
  -t        STR Type (study/lane/file)
  -i        STR Study name, study ID, lane, file of lanes

Options:
  -h                Print this message and exit

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;
