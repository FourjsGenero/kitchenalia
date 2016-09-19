

schema kitchenalia

type product_type record like product.*
define m_product_arr dynamic array of product_type -- used to display multiple rows
define m_arr dynamic array of record
    major string,
    minor string,
    img string
end record

define w ui.window
define f ui.form

define m_toggle  string
define m_filter  string
define m_orderby string



private function exception()
    whenever any error call serious_error
end function


function init()
    let m_toggle = nvl(m_toggle, "desc")
    call db_populate() 
    call ui_populate()
end function

---- Control ----
function list()

    let m_toggle = nvl(m_toggle, "desc")
    
    open window product_list with form "product_list"
    let w= ui.Window.getCurrent()
    let f = w.getform()
    call f.loadToolBar("kitchenalia_list")
    
    call db_populate() 
    call ui_populate()
    call ui_list()
    
    close window product_list
end function




---- User Interface ----
{private }function ui_populate()
define i integer

    call m_arr.clear()
    for i = 1 to m_product_arr.getLength()
        call ui_populate_row(i)
    end for
end function



private function ui_populate_row(l_row)
define l_row integer

    case m_toggle
        when "desc"                     
            let m_arr[l_row].major = m_product_arr[l_row].pr_desc
            let m_arr[l_row].minor = ""
            let m_arr[l_row].img = ""
        
    end case
end function

dialog product_grid()
    menu
        on action cancel
    end menu
end dialog

--private function ui_list()
dialog product_list()
define l_ok boolean
define l_err_text string
define l_popup_value_select boolean

    display array m_arr to scr.* attributes({unbuffered,accept=false, cancel=true, }doubleclick=select, accessorytype=disclosureindicator)

        before display
            if m_arr.getlength() = 0 then
                #call show_message("No data loaded.  Please sync data", true)
            end if
            display "Product ",m_arr.getLength()
 
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
            --let l_popup_value_select = true
            --menu "Display Detail" attributes(style="popup")
                --on action job_code attributes(text="Job Code")
                    --let m_toggle = "job_code"
                --on action job_created attributes(text="Job Created")
                    --let m_toggle = "job_created"
                --on action cancel
                    --let l_popup_value_select = false
            --end menu
            --if l_popup_value_select then
                --call ui_populate()
            --end if
            
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
            
        on action order
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

function ui_list()
 
    if int_flag then
        let int_flag = 0
    end if
end function








---- Database ----
{private }function db_populate()
define l_sql string
define l_rec product_type

    
    call m_product_arr.clear()
    let l_sql = "select * from product"
    if m_filter.getlength() > 0 then
        let l_sql = l_sql, " where ", m_filter
    end if
    if m_orderby.getlength() > 0 then
        let l_sql = l_sql, " order by ", m_orderby
    end if
    declare product_list_curs cursor from l_sql
    foreach product_list_curs into l_rec.*
        let m_product_arr[m_product_arr.getlength()+1].* = l_rec.*
    end foreach
end function