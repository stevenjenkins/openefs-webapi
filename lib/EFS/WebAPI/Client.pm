package EFS::WebAPI::Client;

use EFS::Perl::Depends qw(
    perl5/Moose/1.24
    perl5/libwww-perl/6.02
    perl5/JSON-XS/2.3
    perl5/MooseX-Singleton/0.26
);

use MooseX::Singleton;
use Moose::Util::TypeConstraints;
use LWP::UserAgent;
use JSON::XS;

has _url => ( 
    is      => 'rw',
    isa     => 'Str',
    default => $ENV{ q{EFS_API_URL} } // q{http://efsapi-devserver.example.com/api/v1},
);

has _lwp_ua => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default => sub { LWP::UserAgent->new() },
);

has _json_coder => (
    is  => 'ro',
    isa => 'JSON::XS',
    default => sub { JSON::XS->new() },
);

has status => (
    is  => 'rw',
    isa => enum( [ qw( Success Error ), '' ] ),
);

has result => (
    is  => 'rw',
    isa => 'HashRef | ArrayRef | Undef',
);

has method => ( is => 'rw', isa => 'Str' );

sub is_success {
    my ( $self ) = @_;

    return $self->status eq 'Success' ? 1 : 0;
}

sub call {
    my ( $self, $method, $args ) = @_;

    # clear out any previous results
    $self->status( '' );
    $self->result( undef );
    $self->method( $method );

    my $url = join '/', $self->_url, $method;
    if ( $args && keys %$args ) {
        $url .= '?' . 
            join ';', map "$_=$args->{$_}", keys %$args;
    }

    my $response = $self->_lwp_ua->get( $url );

    if ( ! $response->is_success ) {
        $self->status( 'Error' );
        $self->result( {
            error_code    => 'HTTP Error',
            error_message => $response->status_line,
        } );
    }
    else {
        my $envelope = $self->_json_coder->decode( $response->content() );
        $self->status( $envelope->{ status } );
        $self->result( $envelope->{ result } );
    }

    return $self->status() eq 'Success' ? 1 : 0;
}

1;
