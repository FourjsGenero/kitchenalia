import com
import util

schema kitchenalia

type settings_type record like settings.*
public define m_rec settings_type

private function exception()
    whenever any error call serious_error
end function



function init()
    select * 
    into m_rec.*
    from settings
end function

function execute()
    if ui.Window.forName("settings") is null then
        open window settings with form "settings"
        start dialog settings
    end if
    current window is settings
end function



function device_registered()
    return (m_rec.device_prefix is not null)
end function

function register(l_device_prefix)
define l_device_prefix integer

    let m_rec.device_prefix = l_device_prefix using "&&"
    update settings
    set device_prefix = m_rec.device_prefix
    where 1=1
end function
    



dialog settings()

    input by name m_rec.* attributes(without defaults=true)
        on change url
            update settings
            set url = m_rec.url
            where 1=1

        on change next_customer
            update settings
            set next_customer = m_rec.next_customer
            where 1=1

        on change next_order
            update settings
            set next_order  = m_rec.next_order
        
        on action cancel
            exit dialog
        on action accept
            exit dialog

    on action dummy_add 
        delete from customer where 1=1
        delete from order_header where 1=1
        delete from order_line where 1=1

            insert into customer values ("CM1","Alan Anderson","1 The Avenue","Auckland",NULL,"New Zealand",1000)
            insert into customer values ("CM2","Bob Bailey","2 The Bouleyvard","Blenheim",NULL,"New Zealand",2000)
            insert into customer values ("CM3","Chris Cooper","3 The Chase","Christchurch",NULL,"New Zealand",3000)

            insert into order_header values("ABC123","CM1","2016-08-25", NULL,60,"Alan Anderson","1 The Avenue","Auckland",NULL,"New Zealand",1000)

            insert into order_line values("ABC123",1,"AA000001",1,10,10)
            insert into order_line values("ABC123",2,"AA000002",2,10,20)
            insert into order_line values("ABC123",3,"AA000003",3,10,30)

            insert into order_header values("ABC124","CM2","2016-8-25", NULL,300,"Bob Bailey","2 The Bouleyvard","Blenheim",NULL,"New Zealand",2000)

            insert into order_line values("ABC124",1,"AA000001",10,10,100)
            insert into order_line values("ABC124",2,"AA000002",20,10,200)

            update product 
            set pr_price = 10.00 
            where 1=1
    on action dummy_sync_customer
        call dummy_sync_customer()

    on action dummy_sync_order
        call dummy_sync_order()
    end input
end dialog

function dummy_sync_customer()
define req  com.HttpRequest
define resp com.HttpResponse
define l_customer record like customer.*
define l_url string
define j_customer record
    cu_code string,
    cu_name string,
    cu_address string,
    cu_city string,
    cu_state string,
    cu_country string,
    cu_postcode string,
    cu_phone string,
    cu_mobile string,
    cu_email string,
    cu_website string,
    cu_lat float,
    cu_lon float
end record

    let l_customer.cu_code = "TEST"
    let l_customer.cu_name = "test customer"


    let l_url = "http://localhost:8096/ws/r/kitchenalia_service/create_customer"
    let req = com.HttpRequest.create(l_url)
    call req.setHeader("Content-Type", "application/JSON")
    CALL req.setMethod("POST")
    CALL req.setTimeOut(60)
    CALL req.setVersion("1.0")

    let j_customer.cu_code = l_customer.cu_code
    let j_customer.cu_name = l_customer.cu_name
    let j_customer.cu_address = l_customer.cu_address
    let j_customer.cu_city = l_customer.cu_city
    let j_customer.cu_state = l_customer.cu_state
    let j_customer.cu_country = l_customer.cu_country
    let j_customer.cu_postcode = l_customer.cu_postcode
   # let j_customer.cu_phone = l_customer.cu_phone
   # let j_customer.cu_mobile = l_customer.cu_mobile
   #let j_customer.cu_email = l_customer.cu_email
   # let j_customer.cu_website = l_customer.cu_website
   # let j_customer.cu_lat = l_customer.cu_lat
   #let j_customer.cu_lon = l_customer.cu_con



    
    call req.doTextRequest(util.JSON.stringify(j_customer))

    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        message "OK"
    else
        error "Unable to sync customer"
    end if
end function



function dummy_sync_order()
define req  com.HttpRequest
define resp com.HttpResponse
define l_customer record like customer.*
define l_url string
define j_order record
    oh_code string,
    oh_cu_code string,
    oh_order_date string,
    oh_year float,
    oh_month float,
    oh_upload string,
    oh_order_value float,
    oh_delivery_name string,
    oh_delivery_address string,
    oh_delivery_city string,
    oh_delivery_state string,
    oh_delivery_country string,
    oh_delivery_postcode string,
    lines dynamic array of record
        ol_oh_code string,
        ol_idx float,
        ol_pr_code string,
        ol_qty float,
        ol_price float,
        ol_line_value float
    end record
end record
define l_order_header record like order_header.*
define l_order_line record like order_line.*

    let l_url = "http://localhost:8096/ws/r/kitchenalia_service/create_order"
    let req = com.HttpRequest.create(l_url)
    call req.setHeader("Content-Type", "application/JSON")
    CALL req.setMethod("POST")
    CALL req.setTimeOut(60)
    CALL req.setVersion("1.0")

    let j_order.oh_code = "TEST"
    let j_order.oh_cu_code = "dummy"
    let j_order.oh_order_date = TODAY

    let j_order.lines[1].ol_oh_code = j_order.oh_code
    let j_order.lines[1].ol_idx = 1
    let j_order.lines[1].ol_pr_code = "TESTA"
    let j_order.lines[1].ol_qty = 1
    let j_order.lines[1].ol_price = 10
    let j_order.lines[1].ol_line_value = 10
    let j_order.lines[2].ol_oh_code = j_order.oh_code
    let j_order.lines[2].ol_idx = 2
    let j_order.lines[2].ol_pr_code = "TESTA"
    let j_order.lines[2].ol_qty = 1
    let j_order.lines[2].ol_price = 10
    let j_order.lines[2].ol_line_value = 10
   
   # let j_customer.cu_phone = l_customer.cu_phone
   # let j_customer.cu_mobile = l_customer.cu_mobile
   #let j_customer.cu_email = l_customer.cu_email
   # let j_customer.cu_website = l_customer.cu_website
   # let j_customer.cu_lat = l_customer.cu_lat
   #let j_customer.cu_lon = l_customer.cu_con

   
    display util.JSON.stringify(j_order)
    call req.doTextRequest(util.JSON.stringify(j_order))

    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        message "OK"
    else
        error "Unable to sync customer"
    end if
end function
   