import fgl product_group_list
import fgl product
import fgl browser
import fgl chart


schema kitchenalia

type product_type record like product.*
define m_product_arr dynamic array of product_type -- used to display multiple rows
define m_arr dynamic array of record
    major string,
    minor string,
    img string,
    pr_code like product.pr_code
end record
define m_pr_code like product.pr_code

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

    IF ui.Window.forName("catalog") IS NULL THEN
        open window catalog with form "catalog" attributes(type=left)
        
        let wl = ui.Window.forName("catalog")
        let f = wl.getForm()
        call f.loadToolBar("kitchenalia_list")
        start dialog catalog_list

        open window catalog_detail with form "catalog_detail" attributes(type=right)
        let wg = ui.Window.forName("catalog_detail")
        start dialog catalog_detail

        let m_toggle = "desc"
        call db_populate()
        call ui_populate()
    END IF 
    current window is catalog
end function

dialog catalog_list()
define l_popup_value_select boolean
define l_pr_pg_code like product.pr_pg_code

define l_scanned_pr_code like product.pr_code
define l_scanned_pr_barcode like product.pr_barcode
define l_barcode_type string
define i integer

    display array m_arr to scr.* 
   
        before display
            if m_arr.getlength() = 0 then
                #call show_message("No data loaded.  Please sync data", true)
            end if

        before row
            current window is catalog_detail
            terminate dialog catalog_detail

            let m_pr_code = m_arr[arr_curr()].pr_code
            call wg.setText(m_arr[arr_curr()].major)
            call display_product(arr_curr())
            start dialog catalog_detail
            current window is catalog
            
        --on action toggle
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
            let l_popup_value_select = true
            menu "Filter" attributes(style="popup")
            
                on action all attributes(text="All")
                    initialize m_filter to null
                    
                on action group attributes(text="Group")
                    -- change to all when we have multi row select
                    let m_filter = "group"
                    
                on action cancel
                    let l_popup_value_select = false
            end menu
            if m_filter = "group" then
                let l_pr_pg_code = product_group_list.select()
                if l_pr_pg_code is not null then
                    let m_filter = sfmt("pr_pg_code = '%1'", l_pr_pg_code)
                else
                    initialize m_filter to null
                    let l_popup_value_select = false
                end if
            end if
            call dialog.setActionActive("barcode", m_filter is null)
--
            if l_popup_value_select then
                call db_populate() 
                call ui_populate()
            end if
            
        on action sort
            let l_popup_value_select = true
            menu %"menu.sort.title" attributes(style="popup")
                on action code attributes(text="Code")
                    let m_orderby = "pr_code"
                on action desc attributes(text="Description")
                    let m_orderby = "pr_desc desc"
                #TODO this need sales on product field
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
            call ui.Interface.frontcall("mobile","scanBarCode",[],[l_scanned_pr_barcode, l_barcode_type])
            
            select pr_code
            into l_scanned_pr_code
            from product
            where pr_barcode = l_scanned_pr_barcode

            for i = 1 to m_product_arr.getLength()
                if m_product_arr[i].pr_code = l_scanned_pr_code then
                    call dialog.setCurrentRow("scr",i)
                    exit for
                end if
            end for

    end display
end dialog

function display_product(l_row)
define l_row integer

    display m_product_arr[l_row].pr_code to pr_code
    display m_product_arr[l_row].pr_desc to pr_desc
    display m_product_arr[l_row].pr_price to pr_price
    display m_product_arr[l_row].pr_barcode to pr_barcode

   
    #TODO change img
    display "img/"||product.thumbnail_get( m_product_arr[l_row].pr_code) TO pi_filename
end function

dialog catalog_detail()
define wc string
define l_ol_rec record like order_line.*
define result string
define ok boolean
define err_text string

    input by name wc, l_ol_rec.ol_qty
        on change ol_qty
            let l_ol_rec.ol_line_value = l_ol_rec.ol_qty * l_ol_rec.ol_price
            update order_line
            set ol_qty = l_ol_rec.ol_qty,
            ol_line_value = l_ol_rec.ol_line_value
            where ol_oh_code = ?
            and ol_idx = ?

        on action video
            call browser.browser("Video Example","https://www.youtube.com/watch?v=moYoyKxG3MM")

        on action contact_supplier
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

        on action chart
            #TODO add test connected, or shall we do in library?
            call chart.line_product_sales(m_pr_code) returning ok, err_text
    end input
end dialog

private function ui_populate()
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
            let m_arr[l_row].minor = m_product_arr[l_row].pr_code
            let m_arr[l_row].img = sfmt("img/%1",product.thumbnail_get(m_product_arr[l_row].pr_code))
            let m_arr[l_row].pr_code = m_product_arr[l_row].pr_code
        
    end case
end function


---- Database ----
{private }function db_populate()
define l_sql string
define l_rec product_type

    
    call m_product_arr.clear()
    let l_sql = "select product.* from product"
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


