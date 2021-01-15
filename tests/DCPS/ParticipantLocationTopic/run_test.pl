eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    & eval 'exec perl -S $0 $argv:q'
    if 0;

# -*- perl -*-

my @original_ARGV = @ARGV;

use Env (DDS_ROOT);
use lib "$DDS_ROOT/bin";
use Env (ACE_ROOT);
use lib "$ACE_ROOT/bin";
use PerlDDS::Run_Test;
use strict;

PerlDDS::add_lib_path('../ConsolidatedMessengerIdl');

my $status = 0;

my $test = new PerlDDS::TestFramework();

$test->{dcps_debug_level} = 1;
$test->{dcps_transport_debug_level} = 1;
# will manually set -DCPSConfigFile
$test->{add_transport_config} = 0;

my $no_ice_opt = "";
my $ipv6_opt = "";

foreach my $i (@ARGV) {
  if ($i eq 'noice' || $i eq '-noice') {
    $no_ice_opt = "-n";
  }
  if ($i eq 'ipv6' || $i eq '-ipv6') {
    $ipv6_opt = "-6";
  }
}

my $pub_sub_ini = "rtps.ini";
if ($no_ice_opt && $ipv6_opt) {
    $pub_sub_ini = 'rtps_no_ice_ipv6.ini';
} elsif ($no_ice_opt) {
    $pub_sub_ini = 'rtps_no_ice.ini';
} elsif ($ipv6_opt) {
    $pub_sub_ini = 'rtps_ipv6.ini';
}

if ($ipv6_opt) {
    $test->process("relay", "$ENV{DDS_ROOT}/bin/RtpsRelay", "-DCPSConfigFile relay_ipv6.ini -ApplicationDomain 4 -VerticalAddress [::]:4444 -HorizontalAddress [::1]:11444 ");
} else {
    $test->process("relay", "$ENV{DDS_ROOT}/bin/RtpsRelay", "-DCPSConfigFile relay.ini -ApplicationDomain 4 -VerticalAddress 4444 -HorizontalAddress 127.0.0.1:11444 ");
}

$test->process("publisher", "publisher", "$no_ice_opt $ipv6_opt -ORBDebugLevel 1 -DCPSConfigFile ". $pub_sub_ini);
$test->process("subscriber", "subscriber", "$no_ice_opt $ipv6_opt -ORBDebugLevel 1 -DCPSConfigFile " . $pub_sub_ini);

$test->start_process("relay");
sleep 1;
$test->start_process("publisher");
sleep 1;
$test->start_process("subscriber");

$test->stop_process(180, "subscriber");
$test->stop_process(5, "publisher");

$test->kill_process(5, "relay");

exit $test->finish();
