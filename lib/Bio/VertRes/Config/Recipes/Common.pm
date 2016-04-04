package Bio::VertRes::Config::Recipes::Common;

# ABSTRACT: Common base for recipes

=head1 SYNOPSIS

Common base for recipes
   use Bio::VertRes::Config::Recipes::Common;
   extends 'Bio::VertRes::Config::Recipes::Common';

=cut

use Moose;
use Bio::VertRes::Config::CommandLine::StudyNameSearch;
extends 'Bio::VertRes::Config::Recipes::TopLevelCommon';

before 'create' => sub { 
  my ($self) = @_;
  
  if(defined($self->limits->{project}))
  {
    for my $study_name ( @{$self->limits->{project}} )
    {
      $self->database(Bio::VertRes::Config::CommandLine::StudyNameSearch->new(
        default_database_name => $self->database, 
        config_base => $self->config_base,
        study_name => $study_name,
        )->get_study_database_name_or_default_if_not_found);
    }
  }
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;
