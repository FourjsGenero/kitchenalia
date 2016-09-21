import com
import util

import fgl product_group_list
import fgl product_list

import fgl settings

schema kitchenalia

--define m_count record
    --customer integer,
    --product integer,
    --job_get integer,
    --job_put integer,
    --job_deleted integer
--end record


define m_progress string


private function exception()
    whenever any error call serious_error
end function

function execute()
    if ui.Window.forName("execute") is null then
        open window sync with form "sync"
        start dialog sync
    end if
    current window is sync
end function


dialog sync()
define l_ok boolean
define l_err_text string
    
    menu 
        on action fullsync
            call full_sync(true) returning l_ok, l_err_text
            if l_ok then
                call show_message(l_err_text, true)
                call product_group_list.db_populate()
                call product_group_list.ui_populate()
                call product_list.db_populate()
                call product_list.ui_populate()
            else
                call show_error(l_err_text, true)
            end if
        on action partialsync
            call full_sync(false) returning l_ok, l_err_text
            if l_ok then
                call show_message(l_err_text, true)
                call product_group_list.db_populate()
                call product_group_list.ui_populate()
                call product_list.db_populate()
                call product_list.ui_populate()
            else
                call show_error(l_err_text, true)
            end if
        on action uploadsync
            call not_implemented_dialog()
        on action register
            call register() returning l_ok, l_err_text
            if l_ok then
                call show_message(l_err_text, true)
            else
                call show_error(l_err_text, true)
            end if
    end menu
end dialog 



function full_sync(l_images_flg)
define l_images_flg boolean
define l_ok boolean
define l_err_text string
define l_pr_code like product.pr_code
define l_pi_filename like product_image.pi_filename

    call clear_progress()
    if not test_connected() then
        return false, "Must be connected to internet"
    end if

    --initialize m_count.* to null
    let l_ok = true
    if l_ok then
        call display_progress("Refreshing Product Groups")
        call refresh_product_group() returning l_ok, l_err_text
    end if
    if l_ok then
        call display_progress("Refreshing Customers")
        call refresh_customer() returning l_ok, l_err_text
    end if
    if l_ok then
        call display_progress("Refreshing Suppliers")
        call refresh_supplier() returning l_ok, l_err_text
    end if
    if l_ok then
        call display_progress("Refreshing Products")
        call refresh_product() returning l_ok, l_err_text
    end if
    if l_ok then
        call display_progress("Refreshing Product Images")
        declare product_list_curs cursor with hold from
        "select pr_code from product order by pr_code"
        declare product_list_image_curs cursor with hold from
        "select pi_filename from product_image where pi_pr_code = ? order by pi_idx " 

        foreach product_list_curs into l_pr_code
            call refresh_product_image(l_pr_code) returning l_ok, l_err_text
            if l_images_flg then
                if l_ok then
                    foreach product_list_image_curs using l_pr_code into l_pi_filename
                        call refresh_product_image_filename(l_pi_filename) returning l_ok, l_err_text
                        if not l_ok then
                            exit foreach
                        end if
                    end foreach
                else
                    exit foreach
                end if
            end if
        end foreach
        
    end if

    call display_progress("Finished")

    
   
    --if l_ok then
        --call refresh_job_header() returning l_ok, l_err_text
    --end if
    --if l_ok then
        --call send_jobs() returning l_ok, l_err_text
    --end if
    --if l_ok then
        --call delete_old_jobs() returning l_ok, l_err_text
    --end if
    --if l_ok then
        --let l_err_text = sfmt("%1 new jobs loaded\n%2 product records refreshed\n %3 customer records refresh\n%4 completed jobs uploaded\n%5 old jobs deleted", m_count.job_get, m_count.product, m_count.customer, m_count.job_put, m_count.job_deleted)
    --end if
    return l_ok, l_err_text
end function



--function create_random_job()
--define l_ok boolean
--define l_err_text string
--
--define l_url string
--
--define req com.HttpRequest
--define resp com.HttpResponse
--
--define s string
--
    --if not test_connected() then
        --return false, "Must be connected to internet"
    --end if
--
    --let l_url = "https://demo.4js.com/gas/ws/r/pool_doctors_server/service/createRandomJob"
    #let l_url = "http://bj.bluejs.com/bj/ws/r/bj/pool_doctors_server/createRandomJob"
--
    --let req = com.HttpRequest.create(l_url)
    --
    --call req.setHeader("Content-Type","application/JSON")
    --call req.setMethod("POST")
--
    --call req.doTextRequest(rep using "&&")
--
    --let resp = req.getResponse()
   --
    --if resp.getStatusCode() = 200 then
        --let s = resp.getTextResponse()
        --let l_ok = true
        --let l_err_text = sfmt("New job created %1", s)
    --else
        --let l_ok = false
        --let l_err_text = "Error creating job\n", resp.getStatusDescription()
    --end if
    --return l_ok, l_err_text
--end function







private function refresh_product_group()
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record like product_group.*
    
end record
define i integer
define l_product_group_rec record like product_group.*

    let l_url =  settings.m_rec.url,"/ws/r/kitchenalia/get_product_group"
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        delete from product_group where 1=1
        for i = 1 to j_resp.results.getLength()
            let l_product_group_rec.* = j_resp.results[i].*
            insert into product_group values (l_product_group_rec.*)
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function



private function refresh_product()
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record like product.*
    
end record
define i integer
define l_product_rec record like product.*

    let l_url = "http://localhost:8096/ws/r/kitchenalia/get_product"
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        delete from product where 1=1
        for i = 1 to j_resp.results.getLength()
            let l_product_rec.* = j_resp.results[i].*
            insert into product values (l_product_rec.*)
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function



private function refresh_customer()
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record like customer.*
end record
define i integer
define l_customer_rec record like customer.*

    let l_url = "http://localhost:8096/ws/r/kitchenalia/get_customer"
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        #TODO keep customer records not upload?
        delete from customer where 1=1
        for i = 1 to j_resp.results.getLength()
            let l_customer_rec.* = j_resp.results[i].*
            insert into customer values (l_customer_rec.*)
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function


private function refresh_supplier()
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record like supplier.*
end record
define i integer
define l_supplier_rec record like supplier.*

    let l_url = "http://localhost:8096/ws/r/kitchenalia/get_supplier"
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        delete from supplier where 1=1
        for i = 1 to j_resp.results.getLength()
            let l_supplier_rec.* = j_resp.results[i].*
            insert into supplier values (l_supplier_rec.*)
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function



private function refresh_product_image(l_pi_pr_code)
define l_pi_pr_code like product_image.pi_pr_code

define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record like product_image.*
    
end record
define i integer
define l_product_image_rec record like product_image.*

    let l_url = sfmt("http://localhost:8096/ws/r/kitchenalia/get_product_image?pr_code=%1", l_pi_pr_code clipped)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        delete from product_image where pi_pr_code = l_pi_pr_code
        for i = 1 to j_resp.results.getLength()
            let l_product_image_rec.* = j_resp.results[i].*
            insert into product_image values (l_product_image_rec.*)
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function



private function refresh_product_image_filename(l_pi_filename)
define l_pi_filename like product_image.pi_filename

define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j_resp string
define l_byte byte



    let l_url = sfmt("http://localhost:8096/ws/r/kitchenalia/get_product_image_file?filename=%1", l_pi_filename clipped)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if

    let j_resp = resp.getTextResponse()
    locate l_byte in memory
    call util.Json.parse(j_resp, l_byte)
   
    let l_pi_filename = "img/", l_pi_filename
    call l_byte.writeFile(l_pi_filename)

    return true, ""
end function




private function register()
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record 
        dr_idx integer,
        dr_device_id string
    end record
end record
define i integer
define l_product_rec record like product.*
define l_device_id string

    call clear_progress()
    call ui.interface.frontCall("standard","feinfo","deviceId", l_device_id)
    if l_device_id is null then
        return false,"Unable to determine device id"
    end if

    let l_url = sfmt("%1//ws/r/kitchenalia/register_device?device_id=%2",settings.m_rec.url, l_device_id)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)

    if j_resp.count = 1 then
        call settings.register(j_resp.results[1].dr_idx)
        call display_progress("Device Registered")
        return true,""
    else
        return false,"Unable to register device"
    end if
end function


function phone_home()
define l_status string
define l_lat, l_lon float
define l_url string
define req com.HttpRequest
define resp com.HttpResponse

    try
        call ui.Interface.frontCall("mobile","getGeoLocation",[],[l_status, l_lat, l_lon])
        if l_status = "ok" then
            let l_url = sfmt("%1//ws/r/kitchenalia/phone_home?device_id=%2&lat=%3&lon=%4",settings.m_rec.url, settings.m_rec.device_prefix, l_lat using "<<<-&.&&&&&&", l_lon using "<<<-&.&&&&&&")
            let req = com.HttpRequest.create(l_url)
            call req.doRequest()
            let resp = req.getResponse()
        end if
    catch
        -- ignore error
    end try
    -- ignore response
end function



function download_orders(l_cu_code)
define l_cu_code like customer.cu_code
define l_url string

define req com.HttpRequest
define resp com.HttpResponse

define j util.JSONObject
define s string

define j_resp record
    count float,
    results dynamic array of record 
        order record like order_header.*,
        lines dynamic array of record like order_line.*
    end record
end record
define i,l integer

define l_order_header_rec record like order_header.*
define l_order_line_rec record like order_line.*

    let l_url = SFMT("%1/ws/r/kitchenalia/get_order?cu_code=%2", settings.m_rec.url,  l_cu_code)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)
    begin work
    try
        for i = 1 to j_resp.results.getLength()
            let l_order_header_rec.* = j_resp.results[i].order.*
            insert into order_header values (l_order_header_rec.*)

            for l = 1 to j_resp.results[i].lines.getLength()
                let l_order_line_rec.* = j_resp.results[i].lines[l].*
                insert into order_line values (l_order_line_rec.*)
            end for
        end for
        --let m_count.product = j_resp.results.getLength()
    catch
        rollback work
        return false, sqlca.sqlerrm
    end try
    commit work
    return true, ""
end function






--
--private function send_jobs()
--define l_ok boolean
--define l_err_text string
--
--define l_url string
--
--define req com.HttpRequest
--define resp com.HttpResponse
--
-- case of record/field names important for FGL to JSON process 
--define j_send record
        --Customer string,
        --JobLines dynamic array of record
            --jd_code string,
            --jd_line float,
            --jd_product string,
            --jd_qty float,
            --jd_status string
        --end record,
        --Notes dynamic array of record
            --jn_code string,
            --jn_idx float,
            --jn_note string,
            --jn_when string
        --end record,
        --Photos dynamic array of record
            --jp_code string,
            --jp_idx float,
            --jp_lat float,
            --jp_lon float,
            --jp_photo string,
            --jp_image byte,
            --jp_when string
        --end record,
        --TimeSheets dynamic array of record
            --jt_charge_code_id string,
            --jt_code string,
            --jt_finish string,
            --jt_idx float,
            --jt_start string,
            --jt_text string
        --end record,
        --cm_rep string,
        --jh_address1 string,
        --jh_address2 string,
        --jh_address3 string,
        --jh_address4 string,
        --jh_code string,
        --jh_contact string,
        --jh_customer string,
        --jh_date_created string,
        --jh_date_signed string,
        --jh_name_signed string,
        --jh_phone string,
        --jh_signature string,
        --jh_status string,
        --jh_task_notes string
--end record
--
--define l_sql string
--
--define l_job_header record like job_header.*
--define l_job_detail record like job_detail.*
--define l_job_note record like job_note.*
--define l_job_photo record like job_photo.*
--define l_job_timesheet record like job_timesheet.*   
--define i integer
--
--
    --let l_url = "https://demo.4js.com/gas/ws/r/pool_doctors_server/service/putJob"
    #let l_url = "http://bj.bluejs.com/bj/ws/r/bj/pool_doctors_server/putJob"
--
    --let l_sql = "select * from job_header where jh_status = 'X'"
    --prepare job_header_text from l_sql
    --declare job_header_curs cursor for job_header_text
--
    --let l_sql = "select * from job_detail where jd_code= ? order by jd_line"
    --prepare job_detail_text from l_sql
    --declare job_detail_curs cursor for job_detail_text
--
    --let l_sql = "select * from job_note where jn_code= ? order by jn_idx"
    --prepare job_note_text from l_sql
    --declare job_note_curs cursor for job_note_text
--
    --let l_sql = "select * from job_photo where jp_code= ? order by jp_idx"
    --prepare job_photo_text from l_sql
    --declare job_photo_curs cursor for job_photo_text
--
    --let l_sql = "select * from job_timesheet where jt_code= ? order by jt_idx"
    --prepare job_timesheet_text from l_sql
    --declare job_timesheet_curs cursor for job_timesheet_text
--
    --let m_count.job_put = 0
    --let l_ok = true
--
    --foreach job_header_curs into l_job_header.*
        --let req = com.HttpRequest.create(l_url)
        --
        --call req.setHeader("Content-Type","application/JSON")
        --call req.setMethod("POST")
        --call req.setTimeOut(60)
--
        --call req.setVersion("1.0") -- added this as available in GM 1.1 and allows fastcgi
--
        --initialize j_send.* to null
        --let j_send.cm_rep = rep
        --let j_send.jh_address1 = l_job_header.jh_address1
        --let j_send.jh_address2 = l_job_header.jh_address2
        --let j_send.jh_address3 = l_job_header.jh_address3
        --let j_send.jh_address4 = l_job_header.jh_address4
        --let j_send.jh_code = l_job_header.jh_code
        --let j_send.jh_contact = l_job_header.jh_contact
        --let j_send.jh_customer = l_job_header.jh_customer
        --let j_send.jh_date_created = l_job_header.jh_date_created
        --let j_send.jh_date_signed = l_job_header.jh_date_signed
        --let j_send.jh_name_signed = l_job_header.jh_name_signed
        --let j_send.jh_phone = l_job_header.jh_phone
        --let j_send.jh_signature = l_job_header.jh_signature
        --let j_send.jh_status = l_job_header.jh_status
        --let j_send.jh_task_notes = l_job_header.jh_task_notes
--
        --let i = 0
        --foreach job_detail_curs using l_job_header.jh_code into l_job_detail.*
            --let i = i + 1
            --let j_send.joblines[i].jd_code = l_job_detail.jd_code
            --let j_send.joblines[i].jd_line = l_job_detail.jd_line
            --let j_send.joblines[i].jd_product = l_job_detail.jd_product
            --let j_send.joblines[i].jd_qty = l_job_detail.jd_qty
            --let j_send.joblines[i].jd_status = l_job_detail.jd_status
        --end foreach
--
        --let i = 0
        --foreach job_note_curs using l_job_header.jh_code into l_job_note.*
            --let i = i + 1
            --let j_send.notes[i].jn_code = l_job_note.jn_code
            --let j_send.notes[i].jn_idx = l_job_note.jn_idx
            --let j_send.notes[i].jn_note = l_job_note.jn_note
            --let j_send.notes[i].jn_when = l_job_note.jn_when
        --end foreach
--
        --let i = 0
        --locate l_job_photo.jp_photo_data in file "photo.tmp"
        --foreach job_photo_curs using l_job_header.jh_code into l_job_photo.*
            --let i = i + 1
            --let j_send.photos[i].jp_code = l_job_photo.jp_code
            --let j_send.photos[i].jp_idx = l_job_photo.jp_idx
            --let j_send.photos[i].jp_lat = l_job_photo.jp_lat            
            --let j_send.photos[i].jp_lon = l_job_photo.jp_lon
            --let j_send.photos[i].jp_photo = l_job_photo.jp_photo
            --let j_send.photos[i].jp_when = l_job_photo.jp_when
            --locate j_send.photos[i].jp_image in memory
            --call j_send.photos[i].jp_image.readfile("photo.tmp")
        --end foreach
--
        --let i = 0
        --
        --foreach job_timesheet_curs using l_job_header.jh_code into l_job_timesheet.*
            --let i =i + 1
            --let j_send.timesheets[i].jt_code = l_job_timesheet.jt_code
            --let j_send.timesheets[i].jt_idx = l_job_timesheet.jt_idx
            --let j_send.timesheets[i].jt_start = l_job_timesheet.jt_start
            --let j_send.timesheets[i].jt_finish = l_job_timesheet.jt_finish
            --let j_send.timesheets[i].jt_charge_code_id = l_job_timesheet.jt_charge_code_id
            --let j_send.timesheets[i].jt_text = l_job_timesheet.jt_text
        --end foreach
--
        --call req.doTextRequest(util.JSON.stringify(j_send))
      --
        --let resp = req.getResponse()
   --
        --if resp.getStatusCode() = 200 then
            --let l_ok = true
            --let m_count.job_put = m_count.job_put + 1
        --else
            --let l_ok = false
            --let l_err_text = "Error syncing Job:", l_job_header.jh_code, " ", resp.getStatusCode(), " ", resp.getStatusDescription()
            --exit foreach
        --end if
    --end foreach
    --if not l_ok then
        --return false, l_err_text
    --end if
    --return true, ""
--end function
--
--
--
--private function delete_old_jobs()
--define l_sql string
--define l_jh_code like job_header.jh_code
--
--define l_cutoff_date like job_header.jh_date_signed
--define l_days_to_keep_str string
--define l_days_to_keep interval day to day
--
    -- delete jobs that are more than 7 days old and have been synced
    -- generate interval variable of 7 days and delete form current date
    --let l_days_to_keep_str = "7"
    --let l_days_to_keep  = l_days_to_keep_str
--
    --let l_cutoff_date = current year to minute
    --let l_cutoff_date = l_cutoff_date - l_days_to_keep
--
    --let l_sql = "select jh_code from job_header where jh_status = 'X' and jh_date_signed <= ? "
    --let m_count.job_deleted = 0
  --
    --begin work
    --try
        --prepare delete_old_jobs_text from l_sql
        --declare delete_old_jobs_curs cursor for delete_old_jobs_text
        --foreach delete_old_jobs_curs using l_cutoff_date into l_jh_code
            --delete from job_detail where jd_code = l_jh_code
            --delete from job_note where jn_code = l_jh_code
            --delete from job_photo where jp_code = l_jh_code
            --delete from job_timesheet where jt_code = l_jh_code
            --delete from job_header where jh_code = l_jh_code
            --let m_count.job_deleted = m_count.job_deleted + 1
        --end foreach
    --catch
        --rollback work
        --let m_count.job_deleted = 0
        --return false, sqlca.sqlerrm
    --end try
    --commit work
    --return true, ""
--end function
--


private function test_connected()
define l_ipaddress string

    if not base.Application.isMobile() then
        return true
    end if
    call ui.interface.frontCall("standard","feinfo","ip", l_ipaddress)
    
    -- TODO: This line is required due to bug that prevented the refresh icon appearing
    -- Having this line makes the refresh icon appear
    CALL ui.Interface.refresh()  
    
    if l_ipaddress.getLength() > 0 then
        return true
    end if
    return false
end function



function clear_progress()
    initialize m_progress to null
    display m_progress to progress
    call ui.interface.refresh()
end function

function display_progress(l_text)
define l_text string

    let m_progress =  m_progress.append("\n")
    let m_progress =  m_progress.append(l_text)
    display m_progress to progress
    call ui.Interface.refresh()
end function