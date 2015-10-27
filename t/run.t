#!/usr/bin/perl
# $Id: gprintify 257533 2009-05-23 12:45:15Z guillomovitch $

use strict;
use warnings;

use IPC::Run qw/run/;
use Test::More tests => 84;
use FindBin qw/$Bin/;
use File::Temp qw/tempdir/;

my ($out, $err);
delete $ENV{RPM_BUILD_ROOT};

my @progs = (
    "check_elf_files",
    "clean_files",
    "clean_perl",
    "fix_eol",
    "fix_file_permissions",
    "fix_mo",
    "fix_pamd",
    "fix_xdg",
    "fix_pkgconfig",
    "gprintify",
    "lib_symlinks",
    "relink_symlinks",
    "remove_info_dir",
    "remove_libtool_files"
);

foreach my $prog (@progs) {
    ($out, $err) = run_prog($prog);
    is(  $out, '',                         "$prog stdin without buildroot" );
    like($err, qr/^No build root defined/, "$prog stderr without buildroot");

    $ENV{RPM_BUILD_ROOT} = "foo";

    ($out, $err) = run_prog($prog);
    is(  $out, '',                      "$prog stdin with wrong buildroot" );
    like($err, qr/^Invalid build root/, "$prog stderr with wrong buildroot");

    my $buildroot = tempdir(CLEANUP => 1);

    $ENV{RPM_BUILD_ROOT} = $buildroot;

    ($out, $err) = run_prog($prog);
    is($out, '', "$prog stdin with correct buildroot" );
    is($err, '', "$prog stderr with correct buildroot");

    delete $ENV{RPM_BUILD_ROOT};
}

sub run_prog {
    my ($prog, @args) = @_;

    run (["$Bin/../$prog", @args], \my($in, $out, $err));
    return ($out, $err);
}
