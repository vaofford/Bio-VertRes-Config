package Bio::VertRes::Config::Pipelines::ImportCram;

# ABSTRACT: A class for generating the Import pipeline config file

=head1 SYNOPSIS

A class for generating the Import pipeline config file
   use Bio::VertRes::Config::Pipelines::Import;
   
   my $pipeline = Bio::VertRes::Config::Pipelines::ImportCram->new(database => 'abc');
   $pipeline->to_hash();

=cut

use Moose;
use Bio::VertRes::Config::Pipelines::Common;
extends 'Bio::VertRes::Config::Pipelines::Common';

has 'pipeline_short_name' => ( is => 'ro', isa => 'Str', default => 'import' );
has 'module'              => ( is => 'ro', isa => 'Str', default => 'VertRes::Pipelines::Import_iRODS_cram' );
has 'toplevel_action'     => ( is => 'ro', isa => 'Str', default => '__VRTrack_Import_cram__' );

has '_cramtools_jar'      => ( is => 'ro', isa => 'Str', default => '/software/pathogen/external/apps/usr/share/java/cramtools-2.1.jar' );
has '_cramtools_java'     => ( is => 'ro', isa => 'Str', default => '/software/jdk1.8.0_11/bin/java' );

override 'to_hash' => sub {
    my ($self) = @_;
    my $output_hash = super();
    
    $output_hash->{data}{cramtools_jar}  = $self->_cramtools_jar;
    $output_hash->{data}{cramtools_java} = $self->_cramtools_java;
    
    return $output_hash;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
