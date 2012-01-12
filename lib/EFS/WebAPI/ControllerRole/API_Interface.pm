package EFS::WebAPI::ControllerRole::API_Interface;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use EFS::WebAPI::Exception;

sub dispatch :Path :Args(1) {
    my ( $self, $c, $method ) = @_;

    my $params = $c->request->params();

    my $result;

    my $status = 'Success';

    eval {
        my $meta_method = $self->meta->get_method( $method );
        if ( $meta_method && grep { $_ eq 'API' } @{ $meta_method->attributes() } ) {
            # XXX session info (e.g. authenticated user or token) 
            # should be dealt with here, and passed along as a 
            # key in $params
            $result = $self->$method( $params )
        }
        else {
            EFS::WebAPI::Exception->throw(
                code    => 'Invalid Method',
                message => "Method [$method] is not valid.",
            );
        }

    };

    if ( my $err = Exception::Class->caught( 'EFS::WebAPI::Exception' ) ) {
        $status = 'Error';
        $result = {
            error_code    => $err->code(),
            error_message => $err->message(),
        }
    }
    elsif ( $err = Exception::Class->caught() ) {
        $status = 'Error';
        $result = {
            error_code    => 'Error',
            error_message => "$err",
        };
    }

    # log result
    my $log_message = "method<$method> status<$status>";
    if ( $status eq 'error' ) {
        $log_message .= " error_code<$result->{ error_code }> error_message<$result->{ error_message }>";
    }
    $c->log->info( $log_message );

    $c->stash( payload => {
        status => $status,
        result => $result,
    } );
}



sub end : Private {
    my ( $self, $c ) = @_;

    $c->forward( 'View::JSON' );
}


1;
