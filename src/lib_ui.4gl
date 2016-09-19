private function exception()
    whenever any error call serious_error
end function



-- Return the frontend, GMI or GMA
function frontend()
define l_frontend string
    call ui.Interface.frontCall("standard","feinfo","fename",l_frontend)
    return l_frontend
end function



-- Standard dialog to display messages.  Set second parameter to true to
-- force acknowledgement
function show_message(l_message_text, l_acknowledge) 
define l_message_text string
define l_acknowledge boolean

    if l_acknowledge then
        if l_message_text.getlength() > 0 then
            #call fgl_winmessage("Info", l_message_text,"info")
            menu "Info" attributes(style="dialog", comment=l_message_text)
               on action accept
                  exit menu
            end menu
        end if
    else
        message l_message_text
        call ui.Interface.refresh() -- force display to current window
    end if
end function



-- Standard dialog to display errors.  Set second parameter to true to
-- force acknowledgement
function show_error(l_error_text, l_acknowledge)
define l_error_text string
define l_acknowledge boolean

    if l_acknowledge then
        if l_error_text.getlength() > 0 then
            call fgl_winmessage("Error", l_error_text,"stop")
        end if
    else
        error l_error_text
        call ui.interface.refresh() -- force display to current window
    end if
end function



function not_implemented_dialog()
    call show_message("This has not yet been implemented",true)
end function



function confirm_dialog(l_text)
define l_text string

    -- yes, no dialog with default answer = no, i.e. user has to
    -- explicitly choose yes to do something destructive
    return fgl_winquestion("Warning", l_text,"no","no|yes","",0) == "yes"
end function
    



function confirm_cancel_dialog()
    return confirm_dialog("Are you sure you want to cancel?  You will lose your changes")
end function