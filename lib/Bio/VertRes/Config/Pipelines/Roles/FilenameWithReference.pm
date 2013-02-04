package Bio::VertRes::Config::Pipelines::Roles::FilenameWithReference;
# ABSTRACT: Moose Role to set the logfile name and config filename to include the reference

=head1 SYNOPSIS

Moose Role to set the logfile name and config filename to include the reference

   with 'Bio::VertRes::Config::Pipelines::Roles::FilenameWithReference';

=method log_file_name

Override the default logfile name method to include the reference in the name

=cut



use Moose::Role;

sub _construct_filename
{
  my ($self, $suffix) = @_;
  my $output_filename = "";
  for my $limit_type (qw(project sample library)) {
      if ( defined $self->limits->{$limit_type} ) {
          my $list_of_limit_values = $self->limits->{$limit_type};
          for my $limit_value ( @{$list_of_limit_values} ) {
              $limit_value =~ s/^\s+|\s+$//g;
              $output_filename = $output_filename . '_' . $limit_value;
          }
      }
  }

  $output_filename .= join( '_', ( $self->reference ) );

  $output_filename =~ s!\W+!_!g;
  $output_filename =~ s/_$//g;

  if ( length($output_filename) > 80 ) {
      $output_filename = substr( $output_filename, 0, 76 ) . '_' . int( rand(999) );
  }
  return join( '.', ( $output_filename, $suffix ) );
}

override 'log_file_name' => sub {
    my ($self) = @_;
    return $self->_construct_filename('log');
};

override 'config_file_name' => sub {
    my ($self) = @_;
    return $self->_construct_filename('conf');
};


no Moose;
1;

