#!/usr/bin/env julia
include("banner.jl")
include("domainResolution.jl")
include("portScanner.jl")
include("smtpScan.jl")
import Sockets
import DataStructures
import Printf

using ArgParse

START_PORT = 1
END_PORT = 1000

function parse_arguments()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--target", "-t"
        help = "ip address of target machine"
        arg_type = String
        required = true
        "--start", "-s"
        help = "Start port. Default 1."
        arg_type = Int
        default = 1
        "--end", "-e"
        help = "End port. Default 1001."
        arg_type = Int
        default = 1001
        "--open", "-o"
        help = "Show open ports only. Default false."
        action = :store_true
    end
    return parse_args(s)
end

function scan()
    parsed_args = parse_arguments()
    target = get(parsed_args, "target", "")
    if target == ""
        print("\nNo target was informed!")
        exit(1)
    end
    ip = get_ip_from_host(target)
    start = coalesce(get(parsed_args, "start", missing), START_PORT)
    finish = coalesce(get(parsed_args, "end", missing), END_PORT)
    only_open = coalesce(get(parsed_args, "open", missing), false)
    print_banner()
    print("\n")
    print("Running port scan on target $ip\n")
    openPorts = scan_ports(ip, start, finish, only_open)
    print("\nSearching for SMTP servers\n")
    smtp_scan(ip, openPorts)
    # TODO: Adicionar server header grabbing para identificar o server HTTP
    # TODO: Adicionar scan de diretorios com o dict em txt
    # TODO: Adicionar scan de links na página
end

# Start scanning
scan()
