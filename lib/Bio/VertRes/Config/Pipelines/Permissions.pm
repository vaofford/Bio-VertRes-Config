package Bio::VertRes::Config::Pipelines::Permissions;

# ABSTRACT: A class for generating the Permissions pipeline config file which fixes permissions

=head1 SYNOPSIS

A class for generating the Permissions pipeline config file
   use Bio::VertRes::Config::Pipelines::Permissions;
   
   my $pipeline = Bio::VertRes::Config::Pipelines::Permissions->new(database    => 'abc'
                                                                         config_base => '/path/to/config/base',
                                                                         limits      => { project => ['project name'] });
   $pipeline->to_hash();

=cut

use Moose;
use Bio::VertRes::Config::Pipelines::Common;
use Bio::VertRes::Config::Pipelines::Roles::MetaDataFilter;
extends 'Bio::VertRes::Config::Pipelines::Common';
with 'Bio::VertRes::Config::Pipelines::Roles::MetaDataFilter';

has 'pipeline_short_name'  => ( is => 'ro', isa => 'Str', default => 'permissions' );
has 'module'               => ( is => 'ro', isa => 'Str', default => 'VertRes::Pipelines::Permissions' );
has 'prefix'               => ( is => 'ro', isa => 'Bio::VertRes::Config::Prefix', default => '_permissions_');
has 'toplevel_action'      => ( is => 'ro', isa => 'Str', default => '__VRTrack_Permissions__' );

has '_max_failures'        => ( is => 'ro', isa => 'Int', default => 3 );
has '_max_lanes_to_search' => ( is => 'ro', isa => 'Int', default => 10000 );
has '_limit'               => ( is => 'ro', isa => 'Int', default => 5000 );

override 'to_hash' => sub {
    my ($self) = @_;
    my $output_hash = super();
    $output_hash->{limit}                   = $self->_limit;
    $output_hash->{max_lanes_to_search}     = $self->_max_lanes_to_search;
    $output_hash->{max_failures}            = $self->_max_failures;
    $output_hash->{vrtrack_processed_flags} = { import => 1 };
    $output_hash->{limits}                  = $self->_escaped_limits;
    
    return $output_hash;
};

override '_limits_values_part_of_filename' => sub {
    my ($self) = @_;
    my $output_filename = "";
    my @limit_values;

    if ( defined $self->limits->{'project'} ) {
      my $list_of_limit_values = $self->limits->{'project'};
      for my $limit_value ( @{$list_of_limit_values} ) {
        $limit_value =~ s/^\s+|\s+$//g;
        push( @limit_values, $limit_value );
      }
    }

    if ( @limit_values > 0 ) {
        $output_filename = join( '_', @limit_values );
    }

    return $output_filename;
};

sub _construct_filename
{
  my ($self, $suffix) = @_;
  my $output_filename = $self->_limits_values_part_of_filename();
  return $self->_filter_characters_truncate_and_add_suffix($output_filename,$suffix);
}

override 'log_file_name' => sub {
    my ($self) = @_;
    return $self->_construct_filename('log');
};

override 'config_file_name' => sub {
    my ($self) = @_;
    return $self->_construct_filename('conf');
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;
