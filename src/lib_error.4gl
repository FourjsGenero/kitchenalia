define m_been_here_before boolean
define m_filename string



private function exception()
    whenever any error call serious_error
end function



function start_errorlog(l_filename)
define l_filename string
    let m_filename = l_filename
    call startlog(l_filename)
end function



function serious_error()
define l_exit boolean
define l_text text

    -- Prevent endless loop occuring
    if m_been_here_before then
        exit program 1
    end if
    let m_been_here_before = true
    
    let l_exit = false
    while not l_exit
        menu "Error" attributes(style="dialog", comment="An unexpected error has occured")
            on action accept
                let l_exit = true
                exit menu
                
            on action viewlog attributes(text="View log")
                locate l_text in file m_filename              
                call show_message(l_text, true)
        end menu
    end while

    exit program 1
end function