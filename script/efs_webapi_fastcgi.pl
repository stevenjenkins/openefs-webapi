#!/usr/bin/env perl


use EFS::Perl::Depends qw(
    perl5/Catalyst-Runtime/5.80032
    perl5/Catalyst-Plugin-Static-Simple/0.29
    perl5/Catalyst-Devel/1.33
    perl5/Catalyst-Plugin-ConfigLoader/0.30
    perl5/FCGI/0.72
    perl5/Catalyst-View-JSON/0.33
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
    perl5/TimeDate/1.20
    perl5/Readonly/1.03
    perl5/Text-FormatTable/1.03
    perl5/DBIx-Class/0.08123
    perl5/Date-Manip/6.22
    perl5/Sys-Hostname-FQDN/0.11
    perl5/DBIx-Class-TimeStamp/0.14
    perl5/FCGI-ProcManager/0.22
    efs/core/2.8.1
);

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('EFS::WebAPI', 'FastCGI');

1;

=head1 NAME

efs_webapi_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

efs_webapi_fastcgi.pl [options]

 Options:
   -? -help      display this help and exits
   -l --listen   Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n --nproc    specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires -listen)
   -p --pidfile  specify filename for pid file
                 (requires -listen)
   -d --daemon   daemonize (requires -listen)
   -M --manager  specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e --keeperr  send error messages to STDOUT, not
                 to the webserver
   --proc_title  Set the process title (is possible)

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
