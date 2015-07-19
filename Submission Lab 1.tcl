#Written By Stavan Pandya - 131056
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red



set tracefile1 [open out.tr w]
set winfile [ open winfile w ]
$ns trace-all $tracefile1




set namfile [ open out.nam w ]
$ns namtrace-all $namfile
proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

set n0 [ $ns node ]
set n1 [ $ns node ]
set n2 [ $ns node ]
set n3 [ $ns node ]
set n4 [ $ns node ]
set n5 [ $ns node ]
set n6 [ $ns node ]
set n7 [ $ns node ]
set n8 [ $ns node ]
set n9 [ $ns node ]
set n10 [ $ns node ]

$n1 color Red
$n1 shape box



#c r e a t e l i n k s between t h e nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail


$ns simplex-link $n2 $n4 1Mb 300ms DropTail 
$ns simplex-link $n2 $n9 1Mb 300ms DropTail
$ns simplex-link $n4 $n2 1Mb 300ms DropTail
$ns simplex-link $n9 $n2 1Mb 300ms DropTail


set lan [ $ns newLan " $n2 $n4 $n9 " 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel ]

$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right-up
$ns simplex-link-op $n2 $n4 orient right-up
$ns simplex-link-op $n2 $n9 orient right-down
$ns duplex-link-op $n9 $n10 orient right
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down


$ns queue-limit $n2 $n9 20
$ns queue-limit $n2 $n4 20



set tcp [ new Agent/TCP/Newreno ]
$ns attach-agent $n2 $tcp
set sink [ new Agent/TCPSink/DelAck ]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552

set ftp [ new Application/FTP ]
$ftp attach-agent $tcp


set udp [ new Agent/UDP]
$ns attach-agent $n1 $udp
set null [ new Agent/Null ]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2

set udp [ new Agent/UDP]
$ns attach-agent $n8 $udp
set null [ new Agent/Null ]
$ns attach-agent $n0 $null
$ns connect $udp $null
$udp set fid_ 2



set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 2000
$cbr set rate 0.02Mb
$cbr set random false



$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 124.0 "$ftp stop"
$ns at 125.5 "$cbr stop"


proc plotWindow {tcpSource file} \
{
global ns
set time 0.1 
set now [$ns now]
set cwnd1 [$tcpSource set cwnd_]
puts $file "$now $cwnd1"
$ns at [ expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 " plotWindow $tcp $winfile "
$ns at 125.0 "finish"



$ns run

