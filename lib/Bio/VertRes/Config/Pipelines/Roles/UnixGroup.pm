package Bio::VertRes::Config::Pipelines::Roles::UnixGroup;

# ABSTRACT: Gets unix groups for defined user

use Moose::Role;
use List::MoreUtils qw(uniq);
use Array::Utils qw(:all);
use Bio::VertRes::Config::DatabaseManager;
use Data::Dumper;


has 'admin_user'   => ( is => 'ro', isa => 'Str',             required => 1, default => 'pathpipe' );
has 'admin_groups' => ( is => 'rw', isa => 'ArrayRef',        lazy => 1, builder => '_build__admin_groups' );
has 'unix_group'   => ( is => 'rw', isa => 'Str',             lazy => 1, builder => '_build__unix_group' );
has 'data_access_groups' => ( is => 'rw', isa => 'ArrayRef',  lazy => 1, builder => '_build__data_access_groups' );

sub _build__admin_groups {
  my ($self) = @_;
  my $cmd = 'groups ' . $self->admin_user;
  my $result = `$cmd`;
  my @groups;
  @groups = (split /[:,\s\/]+/, $result) unless ( $result =~ /[N|n]o such user/ );
  return \@groups;
}

sub _build__data_access_groups {
  my ($self) = @_;
  my @data_access_groups;
  if ( $self->can('limits') && defined $self->limits->{'project'} ) {
    my $db_obj = Bio::VertRes::Config::DatabaseManager->new(  host => 'mlwarehouse_host',
                                                              port => 'mlwarehouse_port',
                                                              user => 'mlwarehouse_user',
                                                              password => 'mlwarehouse_password',
                                                              database => 'mlwarehouse',
                                                              database_connect_file => $self->database_connect_file
                                                            );

    my $list_of_project_names = $self->limits->{'project'};
    my @all_data_access_groups;
    for my $project_name ( @{$list_of_project_names} ) {
      my @project_data_access_groups = $db_obj->get_data_access_groups( $project_name );
      if ( scalar @project_data_access_groups > 0 ) {
        push(@all_data_access_groups, @project_data_access_groups)
      }
    }
    if ( scalar @all_data_access_groups >= 1 ) {
      @data_access_groups = uniq(@all_data_access_groups);
    }
  }
  return \@data_access_groups;
}

sub _build__unix_group {
    my ($self) = @_;
    my $unix_group = 'pathogen';
    my @data_access_groups = @{ $self->data_access_groups };
    my @admin_groups = @{ $self->admin_groups };
    my @intersect = intersect( @admin_groups, @data_access_groups );
    $unix_group = $intersect[0] if scalar @intersect > 0;
    return $unix_group;
}

package Bio::VertRes::Config::Pipelines::Roles::UnixGroup::Test;
use Moose;
with 'Bio::VertRes::Config::Pipelines::Roles::UnixGroup';

no Moose;
1;