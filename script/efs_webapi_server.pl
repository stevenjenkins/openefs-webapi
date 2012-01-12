#!/efs/dist/perl5/core/5.10.1/exec/bin/perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}


use EFS::Perl::Depends qw(
    efs/core/3.0
    Date-Manip/6.22
    Date-Calc/6.3
    TimeDate/1.20
    Lingua-EN-Inflect/1.89
    Regexp-Common/2.122
    Params-Validate/0.99
    Readonly/1.03
    Text-FormatTable/1.03
    Sub-Install/0.925
    Params-Util/1.04
    List-MoreUtils/0.32
    DBIx-Class/0.08123-build001
    perl5/SQL-Abstract-Limit/0.12
    Moose/1.24
    Class-Accessor-Chained/0.01
    Sys-Hostname-FQDN/0.11
    DBIx-Class-TimeStamp/0.14
    perl5/Try-Tiny/0.09
    perl5/namespace-clean/0.20
    perl5/Sub-Name/0.05
    perl5/Sub-Identify/0.04
    perl5/Package-Stash/0.29
    perl5/Package-DeprecationManager/0.10
    perl5/B-Hooks-EndOfScope/0.09
    perl5/Variable-Magic/0.46
    perl5/Sub-Exporter/0.982
    perl5/Data-OptList/0.107
    perl5/Module-Find/0.10
    perl5/MRO-Compat/0.11
    perl5/Class-C3-Componentised/1.0008
    perl5/Class-Accessor-Grouped/0.10002
    perl5/Data-Page/2.02
    perl5/Hash-Merge/0.12
    perl5/DateTime/0.65
    perl5/DateTime-Locale/0.45
    perl5/DateTime-TimeZone/1.34
    perl5/Class-Singleton/1.4
    perl5/Class-Load/0.06    
    perl5/DBIx-Class-DynamicDefault/0.03
    perl5/Class-Inspector/1.25
    perl5/Data-Dumper-Concise/2.020
    perl5/SQL-Abstract/1.72
    perl5/Scope-Guard/0.20
    perl5/Context-Preserve/0.01
    perl5/DBI/1.616
    perl5/Math-Base36/0.09

    Catalyst-Runtime/5.80032
    perl5/Catalyst-Plugin-Static-Simple/0.29
    perl5/Catalyst-Devel/1.33
    perl5/Exception-Class/1.32
    perl5/Class-DBI/3.0.17
    perl5/Class-DBI-Oracle/0.51
    perl5/Class-DBI-DATA-Schema/1.00
    perl5/Parallel-ForkManager/0.7.9
    perl5/Net-DNS/0.66
    perl5/Class-Std/0.011
    perl5/Set-Scalar/1.25
    perl5/Filesys-Df/0.92
    perl5/File-ReadBackwards/1.04
    perl5/NetApp/1.1.1
    perl5/Env-Path/0.18
    perl5/File-Type/0.22
    perl5/Catalyst-View-JSON/0.33
);

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('EFS::WebAPI', 'Server');

1;

=head1 NAME

efs_webapi_server.pl - Catalyst Test Server

=head1 SYNOPSIS

efs_webapi_server.pl [options]

   -d --debug           force debug mode
   -f --fork            handle each request in a new process
                        (defaults to false)
   -? --help            display this help and exits
   -h --host            host (defaults to all)
   -p --port            port (defaults to 3000)
   -k --keepalive       enable keep-alive connections
   -r --restart         restart when files get modified
                        (defaults to false)
   -rd --restart_delay  delay between file checks
                        (ignored if you have Linux::Inotify2 installed)
   -rr --restart_regex  regex match files that trigger
                        a restart when modified
                        (defaults to '\.yml$|\.yaml$|\.conf|\.pm$')
   --restart_directory  the directory to search for
                        modified files, can be set multiple times
                        (defaults to '[SCRIPT_DIR]/..')
   --follow_symlinks    follow symlinks in search directories
                        (defaults to false. this is a no-op on Win32)
   --background         run the process in the background
   --pidfile            specify filename for pid file

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

