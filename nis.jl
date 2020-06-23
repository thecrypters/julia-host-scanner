#!/usr/bin/env julia
include("banner.jl")
include("domainResolution.jl")
include("portScanner.jl")
include("smtpScan.jl")
include("httpScan.jl")
include("scanDirs.jl")
include("scanLinks.jl")

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
        default = START_PORT
        "--end", "-e"
        help = "End port. Default 1001."
        arg_type = Int
        default = END_PORT
        "--open", "-o"
        help = "Show open ports only. Default false."
        action = :store_true
        "--smtp"
        help = "Run SMTP server scan for users"
        action = :store_true
        "--files"
        help = "Run HTTP scan for common directories and files"
        action = :store_true
        "--links"
        help = "Run link scan on HTTP server"
        action = :store_true
        "--depth"
        help = "Depth for link scanning."
        arg_type = Int
        default = 2
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
    depth = coalesce(get(parsed_args, "depth", missing), 2)
    only_open = coalesce(get(parsed_args, "open", missing), false)
    run_smtp = coalesce(get(parsed_args, "smtp", missing), false)
    run_dirs = coalesce(get(parsed_args, "files", missing), false)
    run_links = coalesce(get(parsed_args, "links", missing), false)
    print_banner()
    print("\n")
    print("Running port scan on target $ip\n")
    openPorts = scan_ports(ip, start, finish, only_open)
    if run_smtp
        print("\nSearching for SMTP servers\n")
        smtp_scan(ip, openPorts)
    end
    print("\nSearching HTTP(s) servers...\n")
    http_conn, url = http_scan(ip, openPorts)
    server = get_server(http_conn)
    print("\nHTTP Server: $server\n")
    if url !== nothing && run_dirs
        scan_dirs(url)
    end
    if url !== nothing && run_links
        scan_links(url, depth)
    end
    println("\n\nDone! See you next time!")
end

# Start scanning
scan()
