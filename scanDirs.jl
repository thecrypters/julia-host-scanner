import HTTP

dirs = eachline("dirs_wordlist.txt")

function scan_dirs(url)
    print("\nRunning common files and directory scan in $url\n")
    try
        for dir in dirs
            status = 0
            try
                request = HTTP.request("GET", "$url/$dir")
                status = request.status
            catch e
                if isa(e, HTTP.ExceptionRequest.StatusError)
                    status = e.status
                else
                    throw(e)
                end
            end
            if status == 200 || status == 400 || status == 403
                println(dir)
            end
        end
        return true
    catch e
        return false
    end
end
