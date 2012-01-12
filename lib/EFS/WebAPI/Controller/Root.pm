package EFS::WebAPI::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

EFS::WebAPI::Controller::Root - Root Controller for EFS::WebAPI

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 _alive_

Slightly obscure (i.e. undocumented) "I'm still running" method.

=cut

# XXX This method should be refactored into API.pm, so that it will return
# proper JSON, and used for checking server health.
sub _alive_ :Global {
    my ( $self, $c ) = @_;
    
    $c->response->body( 'Alive at: ' . time . ' ' . localtime . "\n" );
}


=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    # XXX change message to "method not defined" ?
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Colin Meyer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
