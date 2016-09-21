import fgl customer_list
import fgl customer
import fgl customer_grid
import fgl product

schema kitchenalia

type order_header_type record like order_header.*
define m_order_header_arr dynamic array of order_header_type -- used to display multiple rows
define m_arr dynamic array of record
    major string,
    minor string,
    img string,
    oh_code like order_header.oh_code
end record
define m_arr_line dynamic array of record
    major string,
    minor string,
    img string,
    ol_idx_code like order_line.ol_idx
end record
define wh, wl ui.window
define f ui.form

define m_toggle  string
define m_filter  string
define m_orderby string


private function exception()
    whenever any error call serious_error
end function


function execute()

    IF ui.Window.forName("order") IS NULL THEN
        open window order with form "order" attributes(type=left)
        let wh = ui.Window.forName("order")
        let f = wh.getForm()
        call f.loadToolBar("kitchenalia_list")
        start dialog order

        open window order_detail with form "order_detail" attributes(type=right)
        let wl = ui.Window.forName("order_detail")
        let f = wl.getForm()
        call f.loadToolBar("kitchenalia_list")
        start dialog order_detail

        let m_toggle = "oh_code"
        call db_populate()
        call ui_populate()
    ELSE
        call db_populate()
        call ui_populate()
    END IF 
    current window is order
end function

dialog order()
define l_popup_value_select boolean
define l_cu_code like customer.cu_code

    display array m_arr to scr.* attributes({unbuffered,accept=false, cancel=true, }doubleclick=select, accessorytype=disclosureindicator)
   
        before display
            if m_arr.getlength() = 0 then
                #call show_message("No data loaded.  Please sync data", true)
            end if

        before row
            current window is order_detail
            terminate dialog order_detail
             
            call wl.setText(m_arr[arr_curr()].major)
            call display_order_detail(arr_curr())
            start dialog order_detail
            current window is order

        on action append
            menu "Customer" attributes(style="dialog")
                on action select attribute(text="Select Account")
                    let l_cu_code = customer_list.select()
                on action create attribute(text="New Customer")
                    let l_cu_code = customer_grid.add()
            end menu
            
        on action select 
            --call job_header_grid.view_job(m_job_header_arr[arr_curr()].jh_code)  
                --returning l_ok, l_err_text
--
            -- repopulate upon return
            --if l_ok then
                --call db_populate() 
                --call ui_populate()
            --else
                --call show_error(l_err_text, TRUE)
            --end if
            
        on action toggle
            let l_popup_value_select = true
            menu "Order Detail" attributes(style="popup")
                on action job_code attributes(text="Order Number")
                    let m_toggle = "oh_code"
                on action job_created attributes(text="Customer")
                    let m_toggle = "cu_name"
                on action cancel
                    let l_popup_value_select = false
            end menu
            if l_popup_value_select then
                call ui_populate()
            end if
            
        on action filter
            let l_popup_value_select = true
            menu "Filter" attributes(style="popup")
            
                on action all attributes(text="All")
                    initialize m_filter to null
                    
                on action customer attributes(text="Customer")
                    -- change to all when we have multi row select
                    let m_filter = "customer"
                    
                on action cancel
                    let l_popup_value_select = false
            end menu
            if m_filter = "customer" then
                let l_cu_code = customer_list.select()
                if l_cu_code is not null then
                    let m_filter = sfmt("oh_cu_code = '%1'", l_cu_code)
                else
                    initialize m_filter to null
                    let l_popup_value_select = false
                end if
            end if
--
            if l_popup_value_select then
                call db_populate() 
                call ui_populate()
            end if
            
        on action sort
            --let l_popup_value_select = true
            --menu "Order" attributes(style="popup")
                --on action job_number attributes(text="Job Number")
                    --let m_orderby = "jh_code"
                --on action date_created attributes(text="Newest to Oldest")
                    --let m_orderby = "jh_date_created desc"
                --on action cancel
                    --let l_popup_value_select = false
            --end menu
--
            --if l_popup_value_select then
                --call db_populate() 
                --call ui_populate()
            --end if

      
            

    end display
end dialog

function display_order_detail(l_row)
define l_row integer
define l_oh record like order_header.*
define l_ol record like order_line.*
define i integer

    select *
    into l_oh.*
    from order_header
    where oh_code = m_order_header_arr[l_row].oh_code

    display by name l_oh.oh_order_date, l_oh.oh_order_value
    display customer.name_get(l_oh.oh_cu_code) to cu_name
    
    declare line_curs cursor for 
        select * from order_line where ol_oh_code = m_order_header_arr[l_row].oh_code
    let i = 0
    call m_arr_line.clear()
    foreach line_curs into l_ol.*
        let i = i + 1
        let m_arr_line[i].major = product.desc_get(l_ol.ol_pr_code)
        let m_arr_line[i].minor = SFMT("%1 @ %2", l_ol.ol_qty USING "----,--&", l_ol.ol_price USING "----,-$&.&&")
        let m_arr_line[i].img = ""
    end foreach
    #display m_product_arr[l_row].pr_code to pr_code
    #display m_product_arr[l_row].pr_desc to pr_desc
end function

dialog order_detail()
define wc string

    display array m_arr_line to scr.*
        on action edit

        on action filter

        on action toggle

        on action sort

        on action add_to_order
            current window is catalog 
    end display
end dialog

private function ui_populate()
define i integer

    call m_arr.clear()
    for i = 1 to m_order_header_arr.getLength()
        call ui_populate_row(i)
    end for
end function



private function ui_populate_row(l_row)
define l_row integer

    case m_toggle
        when "oh_code"                     
            let m_arr[l_row].major = m_order_header_arr[l_row].oh_code
            let m_arr[l_row].minor = sfmt("%1 %2",customer.name_get(m_order_header_arr[l_row].oh_cu_code), m_order_header_arr[l_row].oh_order_date)
            let m_arr[l_row].img = ""
            let m_arr[l_row].oh_code = m_order_header_arr[l_row].oh_code
        when "cu_name"
            let m_arr[l_row].major = customer.name_get(m_order_header_arr[l_row].oh_cu_code)
            let m_arr[l_row].minor = sfmt("%1 %2",m_order_header_arr[l_row].oh_code, m_order_header_arr[l_row].oh_order_date)
            let m_arr[l_row].img = ""
            let m_arr[l_row].oh_code = m_order_header_arr[l_row].oh_code
        
    end case
end function


---- Database ----
{private }function db_populate()
define l_sql string
define l_rec order_header_type

    
    call m_order_header_arr.clear()
    let l_sql = "select * from order_header"
    if m_filter.getlength() > 0 then
        let l_sql = l_sql, " where ", m_filter
    end if
    if m_orderby.getlength() > 0 then
        let l_sql = l_sql, " order by ", m_orderby
    end if
    declare order_header_curs cursor from l_sql
    foreach order_header_curs into l_rec.*
        let m_order_header_arr[m_order_header_arr.getlength()+1].* = l_rec.*
    end foreach
end function




