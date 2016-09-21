import fgl customer
import fgl browser
import fgl chart
import fgl sync


schema kitchenalia

type customer_type record like customer.*
define m_customer_arr dynamic array of customer_type -- used to display multiple rows
define m_arr dynamic array of record
    major string,
    minor string,
    img string,
    cu_code like customer.cu_code
end record
define m_cu_code like customer.cu_code

define wl, wg ui.window
define f ui.form

define m_toggle  string
define m_filter  string
define m_orderby string


private function exception()
    whenever any error call serious_error
end function




function execute()
define f ui.Form

    IF ui.Window.forName("customer_book") IS NULL THEN
        open window customer_book with form "customer_book" attributes(type=left)
        
        let wl = ui.Window.forName("customer_book")
        let f = wl.getForm()
        call f.loadToolBar("kitchenalia_list")
        start dialog customer_book

        open window customer_book_detail with form "customer_book_detail" attributes(type=right)
        let wg = ui.Window.forName("customer_book_detail")
        start dialog customer_book_detail

        let m_toggle = "cu_code"
        call db_populate()
        call ui_populate()
    END IF 
    current window is customer_book
end function

dialog customer_book()
define l_popup_value_select boolean


define l_scanned_cu_code like customer.cu_code
define l_scanned_cu_barcode like customer.cu_code
define l_barcode_type string
define i integer

    display array m_arr to scr.* 
   
        before display
            if m_arr.getlength() = 0 then
                #call show_message("No data loaded.  Please sync data", true)
            end if

        before row
            current window is customer_book_detail
            terminate dialog customer_book_detail

            let m_cu_code = m_arr[arr_curr()].cu_code
            call wg.setText(m_arr[arr_curr()].major)
            call display_customer(arr_curr())
            start dialog customer_book_detail
            current window is customer_book
            
        on action toggle
            let l_popup_value_select = true
            menu "Display Detail" attributes(style="popup")
                on action cu_code attributes(text="Customer Code")
                    let m_toggle = "cu_code"
                on action address attributes(text="Address")
                    let m_toggle = "address"
                on action phone attributes(text="Phone")
                    let m_toggle = "phone"
                on action email attributes(text="E-mail")
                    let m_toggle = "cu_email"
                on action cancel
                    let l_popup_value_select = false
            end menu
            if l_popup_value_select then
                call ui_populate()
            end if
            
        -- on action filter
            
            
        on action sort
            let l_popup_value_select = true
            menu %"menu.sort.title" attributes(style="popup")
                on action code attributes(text="Code")
                    let m_orderby = "cu_code"
                on action desc attributes(text="Description")
                    let m_orderby = "cu_name"
                    
                #TODO this need sales on customer record
                #on action sales attributes(text="Sales)
                    
                on action cancel
                    let l_popup_value_select = false
            end menu
--
            if l_popup_value_select then
                call db_populate() 
                call ui_populate()
            end if
            
        on action barcode ATTRIBUTES(IMAGE="fa-barcode")
            call ui.Interface.frontcall("mobile","scanBarCode",[],[l_scanned_cu_barcode, l_barcode_type])

            --TODO if we want different barcode than customer #
            --select cu_code
            --into l_scanned_pr_code
            --from customer
            --where cu_barcode = l_scanned_pr_barcode
            let l_scanned_cu_code = l_scanned_cu_barcode

            for i = 1 to m_customer_arr.getLength()
                if m_customer_arr[i].cu_code = l_scanned_cu_code then
                    call dialog.setCurrentRow("scr",i)
                    exit for
                end if
            end for

    end display
end dialog

function display_customer(l_row)
define l_row integer

    display by name m_customer_arr[l_row].*

end function

dialog customer_book_detail()
define wc string
define l_ol_rec record like order_line.*
define result string
define ok boolean
define err_text string

    menu

        on action contact_customer
            menu "" attributes(style="popup")
                on action phone
                    try
                        call ui.interface.frontcall("standard","launchUrl",[sfmt("telprompt:%1", "555-5555")],[result])
                    catch
                        let result = 1
                    end try
                    if result > 0 then
                        call show_error("Unable to call", true)
                    end if

                on action email
                    try
                        call ui.Interface.frontCall("mobile","composeMail",["demo@4js.com","","","",""],result)
                    catch
                            let result = 1
                    end try
                    if result > 0 then
                        call show_error("Unable to e-mail", true)
                    end if
                on action web
                    call ui.Interface.frontCall("standard","launchUrl",["http://www.4js.com"],[])
            end menu

        on action download_orders
            call sync.download_orders(m_cu_code) returning ok, err_text

        on action chart_line ATTRIBUTES(IMAGE="fa-line-chart")
            #TODO add test connected, or shall we do in library?
            call chart.line_customer_sales(m_cu_code) returning ok, err_text

        on action chart_pie ATTRIBUTES(IMAGE="fa-pie-chart")
            #TODO add test connected, or shall we do in library?
            call chart.pie_customer_sales(m_cu_code) returning ok, err_text
    end menu
end dialog

private function ui_populate()
define i integer

    call m_arr.clear()
    for i = 1 to m_customer_arr.getLength()
        call ui_populate_row(i)
    end for
end function



private function ui_populate_row(l_row)
define l_row integer

    case m_toggle
        when "cu_code"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_name
            let m_arr[l_row].minor = m_customer_arr[l_row].cu_code
            #let m_arr[l_row].img = sfmt("img/%1",customer.thumbnail_get(m_customer_arr[l_row].cu_code))
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
        when "address"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_name
            let m_arr[l_row].minor = SFMT("%1 %2 %3 %4 %5",m_customer_arr[l_row].cu_address,m_customer_arr[l_row].cu_city,m_customer_arr[l_row].cu_state,m_customer_arr[l_row].cu_country,m_customer_arr[l_row].cu_postcode)
            #let m_arr[l_row].img = sfmt("img/%1",customer.thumbnail_get(m_customer_arr[l_row].cu_code))
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
        when "phone"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_name
            let m_arr[l_row].minor = SFMT("Ph:%1 Mob:%2",m_customer_arr[l_row].cu_phone,m_customer_arr[l_row].cu_mobile)
            #let m_arr[l_row].img = sfmt("img/%1",customer.thumbnail_get(m_customer_arr[l_row].cu_code))
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
        when "cu_email"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_name
            let m_arr[l_row].minor = m_customer_arr[l_row].cu_email
            #let m_arr[l_row].img = sfmt("img/%1",customer.thumbnail_get(m_customer_arr[l_row].cu_code))
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
    end case
end function


---- Database ----
{private }function db_populate()
define l_sql string
define l_rec customer_type

    
    call m_customer_arr.clear()
    let l_sql = "select customer.* from customer"
    if m_filter.getlength() > 0 then
        let l_sql = l_sql, " where ", m_filter
    end if
    if m_orderby.getlength() > 0 then
        let l_sql = l_sql, " order by ", m_orderby
    end if
    declare customer_list_curs cursor from l_sql
    foreach customer_list_curs into l_rec.*
        let m_customer_arr[m_customer_arr.getlength()+1].* = l_rec.*
    end foreach
end function


