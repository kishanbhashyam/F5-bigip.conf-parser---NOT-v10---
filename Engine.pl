#!/usr/bin/perl -w
# Purpose: This script will parse the TCNZ F5 backup config and extract useful info out of it.
#
# USAGE: ./Engine.pl *.bigip.conf
#

use strict;

my (%F5);
my ($i,$POOL_ON_OFF,$VIRTUAL_ON_OFF,$POOL_MULTIPLE_MEMBERS_ON_OFF)=0;
my ($ISLTM)=0;

chomp(my $TODAYDATE=`date +%Y-%m-%d`);
my ($LB_NAME,$POOL_NAME,$VIRTUAL_NAME,$POOL_IP,$MEMBER_IP)=undef;


while ($i <= $#ARGV) {
  open(FILE,"$ARGV[$i]") || die "ERROR - Can't open file $ARGV[$i] for reading: $!";
  my @TEMP_FILE_INPUT = split('/',$ARGV[$i]);
  for (@TEMP_FILE_INPUT) {
    my $TMP = $_;
    if ($TMP =~ /(.*?ORLBS\d{2}).*conf/) {
      $LB_NAME=$1;
 #    print "\t\t### parsing F5 $LB_NAME ###\n";
    }
  }
  while (<FILE>) {
    chomp;
      if ($_ =~ /^ltm pool (.*?) {$/) {
      $POOL_ON_OFF=1;
      $POOL_NAME=$1;
      $ISLTM=1;
      print "POOL $POOL_NAME\n";
    }

    #elsif ($_ =~ /^pool (.*?) {$/) {
    #  $POOL_ON_OFF=1;
    #  $POOL_NAME=$1;
    #  print "POOL $POOL_NAME\n";
    #}

    elsif ($_ =~ /^}$/) {
      $POOL_ON_OFF=0;
      $VIRTUAL_ON_OFF=0;
      $POOL_MULTIPLE_MEMBERS_ON_OFF=0;
      $POOL_NAME=undef;
      $VIRTUAL_NAME=undef;
    }
    elsif ($_ =~ /^ltm virtual (.*?) {$/) {
      $VIRTUAL_ON_OFF=1;
      $VIRTUAL_NAME=$1;
    }
    
    #elsif ($_ =~ /^virtual (.*?) {$/) {
    #  $VIRTUAL_ON_OFF=1;
    #  $VIRTUAL_NAME=$1;
    #   print "VIRTUAL $VIRTUAL_NAME\n";
    #  }

    if($ISLTM==1){
    if ($_ =~ /^\s{4}pool (.*?)$/ && $VIRTUAL_ON_OFF==1) {
     print "F5 $LB_NAME VIRTUAL $VIRTUAL_NAME with POOL $1 detected\n";
      $F5{$LB_NAME}{VIRTUAL}{$VIRTUAL_NAME}=$1;
    }
    elsif ($_ =~ /^\s{4}destination (.*?\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):.*?$/ && $VIRTUAL_ON_OFF==1) {
      $F5{$LB_NAME}{VIP}{$VIRTUAL_NAME}=$1;
      print "VIP $1 for Virtual Name $VIRTUAL_NAME detected\n";
    }
    elsif ($_ =~ /^\s{12}address (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/ && $POOL_ON_OFF==1) {
    print "F5 $LB_NAME;POOL $POOL_NAME; MEMBER $1\n";
      if (exists $F5{$LB_NAME}{POOL}{$POOL_NAME}) {
        my $TMP = scalar(@{$F5{$LB_NAME}{POOL}{$POOL_NAME}});
        $F5{$LB_NAME}{POOL}{$POOL_NAME}[$TMP]=$1;
      }
      else {
        $F5{$LB_NAME}{POOL}{$POOL_NAME}[0]=$1;
      }
    }
                         } else{

  #===========================================================================================
if ($_ =~ /^virtual (.*?) {$/) {
      $POOL_ON_OFF=1;
      $VIRTUAL_NAME=$1;
      print "$VIRTUAL_NAME\n";
    }
   if ($_ =~ /^\s{3}destination\s(.*?):.*$/) {
      $POOL_ON_OFF=1;
      $POOL_IP=$1;
      print "$POOL_IP\n";
    } else {
        #print "couldnt find ip";
    }

   if ($_ =~ /^pool (.*?) {*$/) {
      $POOL_ON_OFF=1;
      $POOL_IP=$1;
      print "$POOL_IP\n";
    } else {
        #print "couldnt find ip";
    }

   if ($_ =~ /((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}?))/) {
      $POOL_ON_OFF=1;
      $MEMBER_IP=$1;
      print "$MEMBER_IP\n";
    } else {
       #print "couldnt find ip";
    }
}

#===========================================================================================================

  $LB_NAME=undef;
  $i++;
}

print "LB NAME,VIRTUAL NAME,VIRTUAL IP,POOL NAME,MEMBER\n";
for my $LB_NAME (keys %F5) {
  for my $VIRTUAL_NAME (sort keys %{$F5{$LB_NAME}{VIRTUAL}}) {
    my $POOL_NAME=$F5{$LB_NAME}{VIRTUAL}{$VIRTUAL_NAME};
    my $VIP=$F5{$LB_NAME}{VIP}{$VIRTUAL_NAME};
    for (@{$F5{$LB_NAME}{POOL}{$POOL_NAME}}) {
      print "$LB_NAME,$VIRTUAL_NAME,$VIP,$POOL_NAME,$_\n";
    }
  }
}
}

#print "\n\n#############VIP IP LIST\n";
#for my $LB_NAME (keys %F5) {
#  for my $VIRTUAL_NAME (sort keys %{$F5{$LB_NAME}{VIRTUAL}}) {
#    my $VIP=$F5{$LB_NAME}{VIP}{$VIRTUAL_NAME};
#    print "$VIP\n";
#  }
#}
                                           
