package Bio::VertRes::Config::Pipelines::MaqMapping;

# ABSTRACT: Base class for the Maq mapper

=head1 SYNOPSIS

Base class for the Maq mapper
   use Bio::VertRes::Config::Pipelines::MaqMapping;

   my $pipeline = Bio::VertRes::Config::Pipelines::MaqMapping->new(
     database => 'abc',
     reference => 'Staphylococcus_aureus_subsp_aureus_ABC_v1',
     limits => {
       project => ['ABC study'],
       species => ['EFG']
     },

     );
   $pipeline->to_hash();

=cut

use Moose;
extends 'Bio::VertRes::Config::Pipelines::Mapping';

has 'slx_mapper'     => ( is => 'ro', isa => 'Str', default => 'maq' );
has 'slx_mapper_exe' => ( is => 'ro', isa => 'Str', default => '/software/solexa/bin/maqexe/maq-0.7.1-6.long.icc.static' );

__PACKAGE__->meta->make_immutable;
no Moose;
1;

