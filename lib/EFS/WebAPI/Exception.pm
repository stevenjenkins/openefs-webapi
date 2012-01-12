package EFS::WebAPI::Exception;

# some Params::Validate hackery, really belongs elsewhere,
# but has to be used in every class that calls validate()
our $throw_validation_exception = sub {
    my ( $message ) = @_;

    $message =~ s/ in call to .*//s;

    EFS::WebAPI::Exception->throw(
        code    => 'Invalid Input',
        message => $message,
    );
};

sub import {
    my ($caller_package) = caller();

    eval qq{
        package $caller_package;
        use Params::Validate ':all';
        validation_options(
            on_fail => \$EFS::WebAPI::Exception::throw_validation_exception,
        );
    }; 
}

use Exception::Class (
    'EFS::WebAPI::Exception' => {
        fields => [ qw( code ) ],
    },
);

1;
