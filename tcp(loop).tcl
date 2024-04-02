set ns [new Simulator]
set val(chan) Channel/WirelessChannel;
set val(prop) Propagation/TwoRayGround;
set val(netif) Phy/WirelessPhy;
set val(mac) Mac/802_11;
set val(ifq) Queue/DropTail/PriQueue;
set val(ll) LL;
set val(ant) Antenna/OmniAntenna;
set val(ifqLen) 50;
set val(nn) 20;
set val(rp) DSDV;

set topo [new Topography]
$topo load_flatgrid 500 500

set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile 500 500

set tracefile [open out.tr w]
$ns trace-all $tracefile

proc finish {} {
    global namfile tracefile
    close $namfile
    close $tracefile
    exec nam out.nam &
    exit
}

create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
    -channelType $val(chan) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -llType $val(ll) \
    -antType $val(ant) \
    -ifqLen $val(ifqLen) \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace ON \

for {set i 0} {$i < $val(nn)} {incr i} {
    set n_($i) [$ns node]
    $n_($i) set X_ [expr int(rand() * 500) + 1]
    $n_($i) set Y_ [expr int(rand() * 500) + 1]
    $n_($i) set Z_ 0
    $ns initial_node_pos $n_($i) 30
    $ns at 1.5 "$n_($i) setdest [expr int(rand() * 500) + 1] [expr int(rand() * 500) + 1] 30"
}

for {set i 0} {$i < [expr $val(nn) / 2]} {incr i} {
    set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    set ftp_($i) [new Application/FTP]
    $ns attach-agent $n_($i) $tcp_($i)
    $ns attach-agent $n_([expr $i + 2]) $sink_($i)
    $ns connect $tcp_($i) $sink_($i)
    $ftp_($i) attach-agent $tcp_($i)
    $ns at 1.0 "$ftp_($i) start"
}

$ns at 12.0 "finish"
$ns run
