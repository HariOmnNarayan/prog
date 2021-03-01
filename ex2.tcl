set ns [new Simulator]

set tf [open ex2.tr w]
$ns trace-all $tf
set nf [open ex2.nam w]
$ns namtrace-all $nf
set cwind [open win2.tr w]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 5Mb 2ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0

set ftp [new Application/FTP]
$ftp attach-agent $tcp0

$ns at 1.2 "$ftp start"
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n0 $sink1
$ns connect $tcp1 $sink1
set telnet [new Application/Telnet]
$telnet attach-agent $tcp1

$ns at 1.5 "$telnet start"
$ns at 10.0 "finish"
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 2.0 "plotWindow $tcp0 $cwind"
$ns at 5.5 "plotWindow $tcp1 $cwind"
proc finish {} {
	global ns tf nf cwind
	$ns flush-trace
	close $tf
	close $nf

	puts "running nam..."
	puts "FTP PACKETS.."
	puts "Telnet PACKETS.."
	exec nam ex2.nam &
        exec xgraph win2.tr & 
	exit 0
}
$ns run

BEGIN {
last = 0
tcp_sz = 0
cbr_sz = 0
total_sz = 0}
{
action = $1;
time = $2;
from = $3;
to = $4;
type = $5;
pktsize = $6;
flow_id = $8;
src = $9;
dst = $10;
seq_no = $11;
packet_id = $12;
if (type == "tcp" && action == "r" && to == "3" )
tcp_sz += pktsize
if (type == "cbr" && action == "r" && to == "3" )
cbr_sz += pktsize
total_sz += pktsize
}
END {
print time, ( tcp_sz * 8 / 1000000)
print time , (tcp_sz * 8 / 1000000 ), ( total_sz * 8 / 1000000)
}
