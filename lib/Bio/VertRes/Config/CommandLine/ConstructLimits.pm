package Bio::VertRes::Config::CommandLine::ConstructLimits;

# ABSTRACT: Put the limits together

=head1 SYNOPSIS

A class to represent multiple top level files. It splits out mixed config files into the correct top level files
   use Bio::VertRes::Config::CommandLine::ConstructLimits;
   
   Bio::VertRes::Config::CommandLine::ConstructLimits->new(input_type => $type, input_id => $id, species => $species)->limits_hash;

=cut

use Moose;
use Bio::VertRes::Config::Exceptions;
use File::Slurper qw[write_text read_text];
use Bio::VertRes::Config::DatabaseManager;

has 'input_type'   => ( is => 'ro', isa => 'Str',   required => 1 );
has 'input_id'     => ( is => 'ro', isa => 'Str',   required => 1 );
has 'species'      => ( is => 'ro', isa => 'Maybe[Str]' );
has 'database_connect_file' => ( is => 'ro', isa => 'Maybe[Str]', default => $ENV{VERTRES_DB_CONFIG} );

sub limits_hash
{
  my ($self) = @_;
  my %limits;

  if($self->input_type eq 'study' && $self->input_id =~ /^[\d]+$/)
  {
    my $db_obj = Bio::VertRes::Config::DatabaseManager->new( host => 'mlwarehouse_host',
                                                             port => 'mlwarehouse_port',
                                                             user => 'mlwarehouse_user',
                                                             password => 'mlwarehouse_password',
                                                             database => 'mlwarehouse',
                                                             database_connect_file => $self->database_connect_file
                                                            );
    my @study_names = $db_obj->get_study_name_from_ssid( $self->input_id );    
    Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'No studies have been found for this Sequencescape ID '.$self->input_id) if( @study_names < 1 );
    $limits{project} = \@study_names;
  }
  elsif($self->input_type eq 'study')
  {
    Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'Invalid identifier '.$self->input_id) if(!defined($self->input_id) ||$self->input_id eq '' );
    $limits{project} = [$self->input_id];
  }
  elsif($self->input_type eq 'library' || $self->input_type eq 'sample')
  {
    Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'Invalid identifier '.$self->input_id) if(!defined($self->input_id) ||$self->input_id eq '' );
    $limits{$self->input_type} = [$self->input_id];
  } 
  elsif($self->input_type eq 'lane')
  {
    Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'Invalid identifier '.$self->input_id) if(!defined($self->input_id) ||$self->input_id eq '' );
    if($self->input_id =~ /^\d+_\d$/)
    {
      $limits{$self->input_type} = [$self->input_id.'(#.+)?'];
    }
    else
    {
      $limits{$self->input_type} = [$self->input_id];
    }
  }
  elsif($self->input_type eq 'file')
  {
    $limits{lane} = $self->_extract_lanes_from_file;
  }
  else
  {
    Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'Invalid type passed in, can only be one of study/file/lane/library/sample not '.$self->input_type);
  }
  
  if(defined($self->species))
  {
    $limits{species} = [$self->species];
  }
  
  return \%limits;
}

sub _extract_lanes_from_file
{
  my ($self) = @_;
  
  my $file_contents  = read_text( $self->input_id ) or Bio::VertRes::Config::Exceptions::FileDoesntExist->throw(error => 'Couldnt open the file '.$self->input_id);
  my @lanes = split(/[\n\r]+/, $file_contents);
  my @filtered_lanes;
  for my $lane (@lanes)
  {
    next if($lane =~ /^#/);
    next if($lane =~ /^\s*$/);
    if($lane =~ /\s/)
    {
      print "Invalid lane name: ".$lane ."\n";
      next;
    }
    $lane = $lane.'(#.+)?' if $lane =~ /^\d+_\d$/;
    push(@filtered_lanes, $lane);
  }
  Bio::VertRes::Config::Exceptions::InvalidType->throw(error => 'No valid lanes have been found in the file '.$self->input_id) if(@filtered_lanes < 1 );
  
  return \@filtered_lanes;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
