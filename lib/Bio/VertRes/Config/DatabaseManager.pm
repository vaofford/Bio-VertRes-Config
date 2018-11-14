package Bio::VertRes::Config::DatabaseManager;

# ABSTRACT: Handles interactions with mlwarehouse database

use Moose;
use Bio::VertRes::Config::Exceptions;
use File::Slurper qw[read_text];
use DBI;

has 'database_connect_file' => (
    is      => 'rw',
    isa     => 'Str',
    default => '/software/pathogen/config/database_connection_details');
has '_database_connection_details' =>
      ( is => 'ro', isa => 'Maybe[HashRef]', lazy => 1, builder => '_build__database_connection_details' );
has '_database_prefix' => ( is => 'ro', isa => 'Str', default => 'mlwarehouse');
has '_host' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__host' );
has '_port' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__port' );
has '_database' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__database' );
has '_user' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__user' );
has '_password' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__password' );
has '_dbh'      => ( is => 'rw', isa => 'DBI::db', lazy => 1, builder => '_build__database_handle' );

sub _build__database_connection_details {
    my ($self) = @_;
    my $connection_details;
    if ( -f $self->database_connect_file ) {
        my $text = read_text( $self->database_connect_file );
        $connection_details = eval($text);
    }
    return $connection_details;
}

sub _build__host {
  my ($self) = @_;
  my $db_host_key = join( '_', $self->_database_prefix, 'host' );
  my $db_host_val = $self->_database_connection_details->{ $db_host_key };
  return $db_host_val;
}

sub _build__port {
  my ($self) = @_;
  my $db_port_key = join( '_', $self->_database_prefix, 'port' );
  my $db_port_val = $self->_database_connection_details->{ $db_port_key };
  return $db_port_val;
}

sub _build__database {
  my ($self) = @_;
  my $db_database_key = join( '_', $self->_database_prefix, 'database' );
  my $db_database_val = $self->_database_connection_details->{ $db_database_key };
  return $db_database_val;
}

sub _build__user {
  my ($self) = @_;
  my $db_user_key = join( '_', $self->_database_prefix, 'user' );
  my $db_user_val = $self->_database_connection_details->{ $db_user_key };
  return $db_user_val;
}
sub _build__password {
  my ($self) = @_;
  my $db_password_key = join( '_', $self->_database_prefix, 'password' );
  my $db_password_val = $self->_database_connection_details->{ $db_password_key };
  return $db_password_val;
}

sub _build__database_handle {
  my ($self) = @_;
  my $connection_str = join(':',('DBI', 'mysql', 'host='.$self->_host, 'port='.$self->_port.';database='.$self->_database ));
  my $dbh = DBI->connect($connection_str, $self->_user, $self->_password, {'RaiseError' => 1, 'PrintError' => 0});
  return $dbh
}

sub get_study_name_from_ssid {
  my ($self, $ssid) = @_;
  my $sql = "select name from study where id_study_lims = '".$ssid."' ";
  my @study_names = $self->_dbh->selectrow_array($sql );
  return @study_names;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


    