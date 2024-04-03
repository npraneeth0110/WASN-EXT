set ns [new Simulator]

set tr [open leach.tr w]
set nf [open leach.nam w]
$ns trace-all $tr
$ns namtrace-all-wireless $nf 500 500

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam leach.nam &
	exit 0
}

set val(chan) Channel/WirelessChannel;
set val(nn) 5;
set val(prop) Propagation/TwoRayGround;
set val(que) Queue/DropTail/PriQueue;
set val(queLen) 50;
set val(mac) Mac/802_11;
set val(netif) Phy/WirelessPhy;
set val(ant) Antenna/OmniAntenna;
set val(rp) AODV;
set val(ll) LL;

set topo [new Topography]
$topo load_flatgrid 500 500

create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
-channelType $val(chan) \
-propType $val(prop) \
-phyType $val(netif) \
-ifqType $val(que) \
-ifqLen $val(queLen) \
-macType $val(mac) \
-antType $val(ant) \
-llType $val(ll) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF\
-movementTrace ON

for {set i 0} {$i < $val(nn)} {incr i} {
	set n($i) [$ns node]
	$n($i) set X_ [expr int(rand() * 500) + 1];
	$n($i) set Y_ [expr int(rand() * 500) + 1];
	$n($i) set Z_ 0;
	$ns initial_node_pos $n($i) 40;
}

for {set i 1} {$i < $val(nn)} {incr i} {
	for {set j 0} {$j < $val(nn)} {incr j} {
		if {$j == $i} {
			continue
		}

		set udp($i,$j) [new Agent/UDP]
		$ns attach-agent $n($i) $udp($i,$j)
		set cbr($i,$j) [new Application/Traffic/CBR]
		$cbr($i,$j) attach-agent $udp($i,$j)

		if {$j == 0} {
			set null($j,$i) [new Agent/Null]
			$ns attach-agent $n(0) $null($j,$i)
			continue
		}

		set null($i,$j) [new Agent/Null]
		$ns attach-agent $n($i) $null($i,$j) 
	}
}

for {set i 1} {$i < $val(nn)} {incr i} {
	for {set j 0} {$j < $val(nn)} {incr j} {
		if {$j == $i} {
			continue
		}
		$ns connect $udp($i,$j) $null($j,$i)
	}
}

for {set i 1} {$i < $val(nn)} {incr i} {
	set energyList($i) 100
}

set maxEnergyNode 1
set timer 0.0

proc setCluster {} {
	global maxEnergyNode energyList val
	for {set i 1} {$i < $val(nn)} {incr i} {
		if {$energyList($i) >= $energyList($maxEnergyNode)} {
			set maxEnergyNode $i
		}
	}
}

proc sendPacket {nodeNum} {
	global timer energyList val cbr ns n
	
	set time 0.0
	for {set i 1} {$i < $val(nn)} {incr i} {
		if {$i == $nodeNum} {
			continue
		}
		
		$n($i) color blue
		$ns at [expr $timer + 0.0 + $time] "$cbr($i,$nodeNum) start"
		$ns at [expr $timer + 0.5 + $time] "$cbr($i,$nodeNum) stop"
		$ns at [expr $timer + 1.0 + $time] "$cbr($nodeNum,0) start"
		$ns at [expr $timer + 1.5 + $time] "$cbr($nodeNum,0) stop"
		set time [expr $time + 0.5]
	}
	set timer [expr $timer + 5.5]
	puts "$nodeNum $timer"
	set energyList($nodeNum) [expr $energyList($nodeNum) - int(rand() * 20)]
}

proc leach {} {
	global timer energyList maxEnergyNode
	while {$timer < 50} {
		setCluster
		sendPacket $maxEnergyNode
		puts "$energyList(1) $energyList(2) $energyList(3) $energyList(4)"
	}
}

leach

$ns at 50.0 "finish"
$ns run
