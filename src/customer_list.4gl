

schema kitchenalia

type customer_type record like customer.*
define m_customer_arr dynamic array of customer_type -- used to display multiple rows
define m_arr dynamic array of record
    major string,
    minor string,
    img string,
    cu_code like customer.cu_code
end record

define w ui.window
define f ui.form

define m_toggle  string
define m_filter  string
define m_orderby string

define m_select_cu_code like customer.cu_code



private function exception()
    whenever any error call serious_error
end function



---- Control ----
function select()

    let m_select_cu_code = null
    let m_toggle = nvl(m_toggle, "address")
    
    open window customer_list with form "customer_list" attributes (type=popup)
    let w= ui.Window.getCurrent()
    let f = w.getform()
    call f.loadToolBar("kitchenalia_list")
    
    call db_populate() 
    call ui_populate()
    call ui_select()
    
    close window customer_list
    return m_select_cu_code
end function




---- User Interface ----
{private} function ui_populate()
define i integer

    call m_arr.clear()
    for i = 1 to m_customer_arr.getLength()
        call ui_populate_row(i)
    end for
end function



private function ui_populate_row(l_row)
define l_row integer

    case m_toggle
        when "name"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_name
            let m_arr[l_row].minor = m_customer_arr[l_row].cu_code
            let m_arr[l_row].img = ""
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
        when "code"                     
            let m_arr[l_row].major = m_customer_arr[l_row].cu_code
            let m_arr[l_row].minor = m_customer_arr[l_row].cu_name
            let m_arr[l_row].img = ""
            let m_arr[l_row].cu_code = m_customer_arr[l_row].cu_code
        when "address"
            let m_arr[l_row].major = sfmt("%1 (%2)", m_customer_arr[l_row].cu_name CLIPPED, m_customer_arr[l_row].cu_code clipped)
            let m_arr[l_row].minor = sfmt("%1 %2 %3 %4 %5", m_customer_arr[l_row].cu_address CLIPPED,
            m_customer_arr[l_row].cu_city clipped,
            m_customer_arr[l_row].cu_state clipped,
            m_customer_arr[l_row].cu_postcode clipped,
            m_customer_arr[l_row].cu_country clipped)
    end case
end function





private function ui_select()
define l_ok boolean
define l_err_text string
define l_popup_value_select boolean

    display array m_arr to scr.* attributes(unbuffered,accept=false, cancel=true, doubleclick=select, accessorytype=checkmark)

        before display
            if m_arr.getlength() = 0 then
                #call show_message("No data loaded.  Please sync data", true)
            end if
            
        on action select 
            let m_select_cu_code= m_arr[arr_curr()].cu_code
            exit display

        on action cancel
            initialize m_select_cu_code to null
            exit display
            
        on action toggle
            let l_popup_value_select = true
            menu "Select Customer Detail" attributes(style="popup")
                on action name attributes(text="Name")
                    let m_toggle = "name"
                on action code attributes(text="Code")
                    let m_toggle = "code"
                on action address attributes(text="Address")
                    let m_toggle = "address"
                on action cancel
                    let l_popup_value_select = false
            end menu
            if l_popup_value_select then
                call ui_populate()
            end if
            
        on action filter
            --let l_popup_value_select = true
            --menu "Filter" attributes(style="popup")
                --on action all attributes(text="All")
                    --initialize m_filter to null
                --on action new attributes(text="New")
                    --let m_filter = "jh_status = 'O'"
                --on action inprogress attributes(text="In-Progress")
                    --let m_filter = "jh_status = 'I'"
                --on action new_inprogress attributes(text="New and in-progress")
                    --let m_filter = "jh_status != 'X'"
                --on action complete attributes(text="Complete")
                    --let m_filter = "jh_status = 'X'"
                --on action cancel
                    --let l_popup_value_select = false
            --end menu
--
            --if l_popup_value_select then
                --call db_populate() 
                --call ui_populate()
            --end if
            
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
    if int_flag then
        let int_flag = 0
    end if
end function








---- Database ----
{private} function db_populate()
define l_sql string
define l_rec customer_type

    
    call m_customer_arr.clear()
    let l_sql = "select * from customer"
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