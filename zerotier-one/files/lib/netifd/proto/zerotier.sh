#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

ZT_CLI_COMMAND=/usr/bin/zerotier-cli
HOME_DIR=/var/lib/zerotier-one
DEVICEMAP=$HOME_DIR/devicemap
IFUP_SCRIPT=/etc/zerotier.ifup

get_status() {
	local networkid=$2
	local s=`$ZT_CLI_COMMAND listnetworks | grep $networkid | awk '{print $6}'`
	eval "$1=$s"
}

get_ipinfo() {
	local networkid=$3
	local ipinfo=`$ZT_CLI_COMMAND listnetworks | grep $networkid | awk '{print $9}'`
	local info4=`echo $ipinfo | awk '{split($0,array,",")} END{print array[1]}'`
	local info6=`echo $ipinfo | awk '{split($0,array,",")} END{print array[2]}'`
	eval "$1=$info4"
	eval "$2=$info6"
}

get_ip() {
	local ipinfo=$3
	local ip=`echo $ipinfo | awk '{split($0,array,"/")} END{print array[1]}'`
	local m=`echo $ipinfo | awk '{split($0,array,"/")} END{print array[2]}'`
	eval "$1=$ip"
	eval "$2=$m"
}

proto_zerotier_init_config() {
	no_device=1
	available=1

	proto_config_add_string networkid
	proto_config_add_boolean allowmanaged
	proto_config_add_boolean allowglobal
	proto_config_add_boolean allowdefault
	proto_config_add_int mtu
}

proto_zerotier_setup() {
	local config="$1"
	local link="zt-$config"
	local wanif ip4info ip6info networkid allowmanaged allowglobal allowdefault mtu
	json_get_vars networkid allowmanaged allowglobal allowdefault mtu
	[ ! -n "$allowmanaged" ] && allowmanaged=1

	if ! network_find_wan wanif; then
		proto_notify_error "$config" "NO_WAN_LINK"
		return
	fi

	if ! network_get_ipaddr ipaddr "$wanif"; then
		proto_notify_error "$config" "NO_WAN_LINK"
		return
	fi

	sleep 2

	sed -i "/$networkid=/d" $DEVICEMAP
	echo $networkid=$link >> $DEVICEMAP
#	sed -i "/$networkid=/ s/=.*/=$link/" $DEVICEMAP

	$ZT_CLI_COMMAND join $networkid
	$ZT_CLI_COMMAND set $networkid allowManaged=$allowmanaged

	proto_init_update "$link" 1
	[ $allowmanaged == "1" ] && {
		while [ "$status" != "OK" ]
		do
			sleep 2
			get_status status $networkid
		done
		get_ipinfo ip4info ip6info $networkid
		get_ip ipv4addr ipv4mask $ip4info
		get_ip ipv6addr ipv6mask $ip6info
		proto_add_ipv4_address "$ipv4addr" "$ipv4mask"
		proto_add_ipv6_address "$ipv6addr" "$ipv6mask"
	}
	proto_send_update "$config"

	$ZT_CLI_COMMAND set $networkid allowDefault=$allowdefault
	$ZT_CLI_COMMAND set $networkid allowGlobal=$allowglobal
	[ -n "$mtu" ] && ifconfig $link mtu $mtu

	[ -x "$IFUP_SCRIPT" ] && $IFUP_SCRIPT $link
}

proto_zerotier_teardown() {
	local config="$1"
	local networkid
	json_get_vars networkid
	$ZT_CLI_COMMAND leave $networkid
}

[ -n "$INCLUDE_ONLY" ] || {
	[ -x /etc/rc.d/S90zerotier ] && {
		add_protocol zerotier
	}
}

