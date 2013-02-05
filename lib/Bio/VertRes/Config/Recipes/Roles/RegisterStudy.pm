package Bio::VertRes::Config::Recipes::Roles::RegisterStudy;
# ABSTRACT: Moose Role for registering a study

=head1 SYNOPSIS

Moose Role for registering a study

   with 'Bio::VertRes::Config::Recipes::Roles::RegisterStudy';

=method create

Hooks into the create method after the base method is run to register a study

=cut

use Moose::Role;

# Register all the studies passed in the project limits array
after 'create' => sub { 
  my ($self) = @_;
  
  if(defined($self->limits->{project}))
  {
    for my $study_name ( @{$self->limits->{project}} )
    {
      my $pipeline = Bio::VertRes::Config::RegisterStudy->new(
        database    => $self->database, 
        study_name  => $study_name, 
        config_base => $self->config_base
      );
      $pipeline->register_study_name();
    }
  }
};


no Moose;
1;


