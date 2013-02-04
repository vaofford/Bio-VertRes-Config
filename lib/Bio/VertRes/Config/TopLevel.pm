package Bio::VertRes::Config::TopLevel;

# ABSTRACT: A top level config file for a pipeline

=head1 SYNOPSIS

A top level config file for a pipeline. This specifies all of the sub configs to execute
   use Bio::VertRes::Config::TopLevel;
   
   my $pipeline = Bio::VertRes::Config::TopLevel->new(database => 'abc', pipeline_configs => [$config_obj1, $config_obj2]);
   $pipeline->update_or_create();

=cut

use Moose;
use File::Basename;
use File::Path qw(make_path);
use Bio::VertRes::Config::Exceptions;
with 'Bio::VertRes::Config::Pipelines::Roles::RootDatabaseLookup';

has 'pipeline_short_name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'database'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'pipeline_configs'            => ( is => 'ro', isa => 'ArrayRef', required => 1 );

has 'overall_config'                   => ( is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_overall_config' );
has 'overall_config_base'              => ( is => 'ro', isa => 'Str',     default => '/nfs/pathnfs01/conf' );
has 'overall_config_file_name'         => ( is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_overall_config_file_name' );
has '_overall_config_file_name_suffix' => ( is => 'ro', isa => 'Str',     default => 'pipeline.conf' );
has '_filenames_to_action'             => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__filenames_to_action' );


sub _build_overall_config_file_name {
    my ($self) = @_;
    return join( '_', ( $self->root_database_name, $self->pipeline_short_name, 'pipeline.conf' ) );
}

sub _build_overall_config {
    my ($self) = @_;
    return join( '/', ( $self->overall_config_base, $self->root_database_name, $self->overall_config_file_name ) );
}

sub _build__filenames_to_action {
    my ($self) = @_;
    my %filenames_to_action;
    
    # If the pipeline config file exists already, open it up and pull out all the details
    if(-e $self->overall_config)
    {
      open(my $overall_config_fh, $self->overall_config) or Bio::VertRes::Config::Exceptions::FileDoesntExist->throw(error => 'Couldnt open file '.$self->overall_config);
      while(<$overall_config_fh>)
      {
        chomp;
        my $line = $_;
        next if($line =~ /^#/);
        next if($line =~ /^\s*$/);
        if($line =~ /^([\S]+)\s+([\S]+)$/)
        {
          $filenames_to_action{$2} = $1;
        }
      }
    }
    
    for my $pipeline_config (@{$self->pipeline_configs})
    {
      $filenames_to_action{$pipeline_config->config_file_name} = $pipeline_config->toplevel_action;
    }
    
    return \%filenames_to_action;
}

sub update_or_create {
    my ($self) = @_;
    
    # Make sure the directory structure exists before creating the file
    if(!(-e $self->overall_config))
    {
      my($overall_config_filename, $directories, $suffix) = fileparse($self->overall_config);
      make_path($directories);
    }
    
    open(my $overall_config_fh, '+>', $self->overall_config) or Bio::VertRes::Config::Exceptions::FileCantBeModified->throw(error => 'Couldnt open file for writing '.$self->overall_config);    
    
    for my $filename (keys %{$self->filenames_to_action})
    {
      print {$overall_config_fh} $self->filenames_to_action->{$filename}.' '.$filename."\n";
    }
    close($overall_config_fh);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
