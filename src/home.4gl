import fgl chart


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
define l_choice string
define ok boolean
define l_err_text string

   menu
        before menu
            call display_image()

        on action windowresized
            call display_image()

        on action db_status
            call db_status()

        on action about
            menu "" attributes(style="dialog", comment=%"about.text")
                on action fourjs attributes(text="Visit 4Js Website")
                    let l_choice = "fourjs"
                on action generomobile attributes(text="Visit GeneroMobile Website")
                    let l_choice = "generomobile"
                on action tramontina attributes(text="Visit Tramontina Website")
                    let l_choice = "tramontina"
                on action accept
                    let l_choice = ""
                    exit menu
            end menu
            case l_choice
                when "fourjs"
                    call ui.Interface.frontCall("standard","launchurl","http://www.4js.com",[])
                when "generomobile"
                    call ui.Interface.frontCall("standard","launchurl","http://www.generomobile.com",[])
                when "tramontina"
                    call ui.Interface.frontCall("standard","launchurl","http://www.tramontina.com.br/home/index/language/en",[])
            end case


        
    end menu
end dialog



function display_image()
define l_width, l_height integer
    call window_size() returning l_width, l_height
    if l_width > l_height then
        display "ios/ipad/kitchenalia-Landscape.png" to splash
    else 
        display "ios/ipad/kitchenalia-Portrait.png" to splash
    end if
end function


function db_status()
define l_count integer
define sb base.StringBuffer

    let sb = base.stringbuffer.create()
    select count(*) into l_count from product
    call sb.append(SFMT("%1 products", l_count))
    select count(*) into l_count from customer
    call sb.append(SFMT("\n%1 customers", l_count))
    select count(*) into l_count from order_header
    call sb.append(SFMT("\n%1 orders", l_count))

    menu "Database Status" attributes(style="dialog", comment=sb.toString())
        on action accept
            exit menu
    end menu
end function
    