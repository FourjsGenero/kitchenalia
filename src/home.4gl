
private function exception()
    whenever any error call serious_error
end function

function execute()
    if ui.Window.forName("home") is null then
        open window home with form "home"
        start dialog d_home
    end if
    current window is home
end function

dialog d_home()

   menu
        before menu
            call display_image()
        on action windowresized
            call display_image()
        on action about
            call fgl_winmessage(%"about.title",%"about.text","info")
    end menu
end dialog

function display_image()
define l_size string
define l_width, l_height integer
define l_pos integer
    CALL ui.Interface.frontCall("standard","feInfo",["windowSize"],[l_size])
    let l_pos = l_size.getIndexOf("x",1)
    let l_width = l_size.subString(1,l_pos-1)
    let l_height = l_size.subString(l_pos+1, l_size.getLength())
    if l_width > l_height then
        display "ios/ipad/kitchenalia-Landscape@2x.png" to splash
    else #TODO Use 2x image when avail
        display "ios/ipad/kitchenalia-Portrait.png" to splash
    end if
end function
    