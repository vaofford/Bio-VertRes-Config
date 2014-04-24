package Bio::VertRes::Config::MultipleTopLevelFiles;

# ABSTRACT: A class to represent multiple top level files. It splits out mixed config files into the correct top level files

=head1 SYNOPSIS

A class to represent multiple top level files. It splits out mixed config files into the correct top level files
   use Bio::VertRes::Config::MultipleTopLevelFiles;
   
   my $pipeline = Bio::VertRes::Config::MultipleTopLevelFiles->new(database => 'abc', pipeline_configs => [$config_obj1, $config_obj2]);
   $pipeline->update_or_create();

=cut

use Moose;
use Bio::VertRes::Config::TopLevel;

has 'database'         => ( is => 'ro', isa => 'Str',      required => 1 );
has 'pipeline_configs' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'config_base'  => ( is => 'ro', isa => 'Str',     required => 1 );

sub update_or_create {
    my ($self) = @_;

    my %short_name_to_configs;
    my %configs_requiring_approval;

    # split by short name
    for my $pipeline_config ( @{ $self->pipeline_configs } ) {
        # Create the config file
        $pipeline_config->create_config_file;
        if ( !defined( $short_name_to_configs{ $pipeline_config->pipeline_short_name } ) ) {
            $short_name_to_configs{ $pipeline_config->pipeline_short_name } = [];
        }
        push( @{$short_name_to_configs{ $pipeline_config->pipeline_short_name }}, $pipeline_config );
    }

    for my $pipeline_short_name ( keys %short_name_to_configs ) {
        my $toplevel_config = Bio::VertRes::Config::TopLevel->new(
            database            => $self->database,
            pipeline_configs    => $short_name_to_configs{$pipeline_short_name},
            pipeline_short_name => $pipeline_short_name,
            config_base => $self->config_base
        );
        $toplevel_config->update_or_create();

       # Does an admin email need to be sent telling them about config files which need approval?
       if( $toplevel_config->admin_email_needs_to_be_sent == 1 )
       {
         $configs_requiring_approval{$toplevel_config->overall_config}++;
       }

    }
    
    if(keys %configs_requiring_approval > 0)
    {
      $self->email_admins_for_approval(\%configs_requiring_approval);
    }
    
    return $self;
}

sub email_admins_for_approval
{
  my ($self,$files_requiring_approval) = @_;
  1;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
