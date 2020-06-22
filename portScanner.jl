using DataStructures
using Sockets
using Printf

CLOSED_MSG = "ECONNREFUSED"
RESET_MSG = "ECONNRESET"

Host = Union{IPAddr,String}

function print_results(start::Int, finish::Int, output::Dict, only_open::Bool)
    for i in start:finish
        value = output[i]
        if only_open && value != "OPEN"
            continue
        end
        @printf("Port %5d - %s\n", i, value)
    end
end

function scan_ports(target::Host, start::Int, finish::Int, only_open::Bool)
    ports = Dict{Int64,String}()
    open_count = 0
    closed_count = 0
    filtered_count = 0
    print("Running port scanning for $target\n\n")
    start_time = time()
    @sync for port = start:finish
        @async begin
            try
                socket = Sockets.connect(target, port)
                push!(ports, port => "OPEN")
                open_count += 1
                close(socket)
            catch e
                if isa(e, Base.IOError)
                    # Closed port
                    if occursin(CLOSED_MSG, e.msg)
                        push!(ports, port => "CLOSED")
                        closed_count += 1
                    end
                    # Filtered port
                    if occursin(RESET_MSG, e.msg)
                        push!(ports, port => "FILTERED")
                        filtered_count += 1
                    end
                end
            end
        end
    end
    elapsed_time = time() - start_time
    if (open_count + closed_count + filtered_count) == 0
        print("Looks like the host is down :(\n\n")
        exit(0)
    end
    print("TCP port scanning complete!\n")
    print("$open_count open ports, $closed_count closed and $filtered_count filtered\n")
    print_results(start, finish, ports, only_open)
    println("\nFinished in $elapsed_time seconds")
end
