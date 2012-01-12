package EFS::WebAPI::View::JSON;

use base qw{ Catalyst::View::JSON };

__PACKAGE__->config( 
    allow_callback => 0,
    expose_stash   => 'payload',
);


# ================================
# debugging only ... !
# useful for JSON errors when an 
# unexpected object is encountered or similar
#

#   use JSON::XS ();
# 
#   sub encode_json {
#       my($self, $c, $data) = @_;
#       my $encoder = JSON::XS->new->ascii->pretty->allow_blessed;
#       $encoder->encode($data);
#   }

# end debugging gunk
# ================================


1;
