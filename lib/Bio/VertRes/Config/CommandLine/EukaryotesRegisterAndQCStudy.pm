package Bio::VertRes::Config::CommandLine::EukaryotesRegisterAndQCStudy;

# ABSTRACT: Create config scripts to map helminths

=head1 SYNOPSIS

Create config scripts to map helminths

=cut

use Moose;
extends 'Bio::VertRes::Config::CommandLine::RegisterAndQCStudy';

has 'database'    => ( is => 'rw', isa => 'Str', default => 'pathogen_euk_track' );

override 'register_and_qc_usage_text' => sub {
    my ($self) = @_;
    return <<USAGE;
Usage: eukaryote_register_and_qc_study [options]
Pipeline to register and QC a eukaryote study.

# Search for an available reference
eukaryote_register_and_qc_study -a "Plasmodium"

# Register and QC a study
eukaryote_register_and_qc_study -t study -i 1234 -r "Plasmodium_falciparum_3D7_02April2012"

# Register and QC a single lane
eukaryote_register_and_qc_study -t lane -i 1234_5#6 -r "Plasmodium_falciparum_3D7_02April2012"

# Register and QC a file of lanes
eukaryote_register_and_qc_study -t file -i file_of_lanes -r "Plasmodium_falciparum_3D7_02April2012"

# Register and QC a single species in a study
eukaryote_register_and_qc_study -t study -i 1234 -r "Plasmodium_falciparum_3D7_02April2012" -s "Plasmodium falciparum"

# This help message
register_and_qc_study -h

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;