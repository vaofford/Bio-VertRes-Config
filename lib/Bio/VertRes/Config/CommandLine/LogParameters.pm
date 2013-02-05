package Bio::VertRes::Config::CommandLine::LogParameters;

# ABSTRACT: A class to represent multiple top level files. It splits out mixed config files into the correct top level files

=head1 SYNOPSIS

A class to represent multiple top level files. It splits out mixed config files into the correct top level files
   use Bio::VertRes::Config::CommandLine::LogParameters;
   
   Bio::VertRes::Config::CommandLine::LogParameters->new( args => \@ARGV, log_file => '/path/to/log/file')->create;
   

=cut

use Moose;
use Bio::VertRes::Config::Exceptions;
use File::Basename;
use File::Path qw(make_path);

has 'args'         => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'log_file'     => ( is => 'ro', isa => 'Str',    default => '/nfs/pathnfs01/conf/command_line.log' );

sub create
{
  my ($self) = @_;
  
  if(!(-e $self->log_file))
  {
    my($config_filename, $directories, $suffix) = fileparse($self->log_file);
    make_path($directories);
  }
  
  open(my $fh, '+>>', $self->log_file) or Bio::VertRes::Config::Exceptions::FileCantBeModified->throw(error => 'Couldnt open file for writing '.$self->log_file);    
  print {$fh} join(' ', @{$self->args}). "\n";
  close($fh);

  return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
