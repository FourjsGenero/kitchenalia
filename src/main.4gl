import fgl home
import fgl catalog
import fgl order
import fgl customer_list
import fgl sync
import fgl settings

main
define counter integer

    options field order form
    options input no wrap 
    
    call start_errorlog("kitchenalia.log")
    whenever any error call serious_error
    
    call ui.Interface.setText("Kitchenalia")
    call ui.Interface.setImage("app/app_pdi_Spotlight@2x.png")
    
    call ui.Interface.loadStyles("kitchenalia")
    call ui.Interface.loadActionDefaults("kitchenalia")
    call ui.Dialog.setDefaultUnbuffered(true)
    
    call init_database()

    close window screen

    open window dialog_main with 1 rows, 2 columns attribute(type=navigator, style="tabbar")
    start dialog dialog_main

    let counter = 0
    while fgl_eventloop()
        if counter mod 10 = 0 then
            call sync.phone_home()
        end if
        let counter = counter + 1
    end while
end main



dialog dialog_main()
define l_ok boolean
define l_err_text string

    menu
        before menu
            call settings.init()
            call home.execute()
            
        on action home 
            call home.execute()

        on action catalog 
            call catalog.execute()

        on action order 
            call order.execute()

        on action sync 
            call sync.execute()
            
        on action settings 
            call settings.execute()
        
                
            
        
            
    end menu
end dialog



private function init_database()
define l_database_exists boolean
define ch base.channel

    -- First attempt to connect to database.
    -- If this successed we know the database exists
    LET l_database_exists = true
    try
        connect to "kitchenalia"
    catch
        let l_database_exists = false
    end try

    
    if l_database_exists then
        -- Database exists.
        -- In later versions of app, upgrade database here

        -- We are done and can carry on with app
        return
    end if

    -- If get to there, there is no database, need to create it
    -- Warning if in development mode
    if not base.Application.isMobile() then
        if not confirm_dialog("About to create database.  Are you sure?") then
            call errorlog("User cancelled database creation")
            exit program 1
        end if
    end if

    -- Database doesn't exist so we need to create a new empty database file
    -- Should use FGL_GETRESOURCE(dbi.database.catalog.source) here instead
    -- of hard-coded filename
    try
        let ch = base.Channel.create()
        call ch.openFile("kitchenalia.db","w")
        call ch.close()
    catch
        call errorlog("Unable to create empty database")
        exit program 1
    end try

    -- Connect to new empty database
    try
        connect to "kitchenalia"
    catch
        -- Something has gone wrong
        call errorlog("Unable to connect to empty database")
        exit program 1
    end try

    -- Create Tables
    call db_create_tables()

    -- Create Indexes
    call db_add_indexes()

    -- insert initial data if required
    insert into settings
    values("http://localhost:8096",NULL,1,1)
end function








#+ Create all tables in database.
FUNCTION db_create_tables()
    WHENEVER ERROR STOP

  EXECUTE IMMEDIATE "CREATE TABLE product (
        pr_code CHAR(8) NOT NULL,
        pr_desc VARCHAR(80) NOT NULL,
        pr_pg_code CHAR(2) NOT NULL,
        pr_price DECIMAL(11,2),
        pr_barcode VARCHAR(20),
        CONSTRAINT pk_product_1 PRIMARY KEY(pr_code),
        CONSTRAINT fk_product_product_group_1 FOREIGN KEY(pr_pg_code)
            REFERENCES product_group(pg_code))"
    EXECUTE IMMEDIATE "CREATE TABLE product_image (
        pi_pr_code CHAR(8) NOT NULL,
        pi_idx INTEGER NOT NULL,
        pi_filename VARCHAR(80) NOT NULL,
        CONSTRAINT pk_product_image_1 PRIMARY KEY(pi_pr_code, pi_idx),
        CONSTRAINT fk_product_image_product_1 FOREIGN KEY(pi_pr_code)
            REFERENCES product(pr_code))"
    EXECUTE IMMEDIATE "CREATE TABLE product_group (
        pg_code CHAR(2) NOT NULL,
        pg_desc VARCHAR(80) NOT NULL,
        CONSTRAINT pk_product_group_1 PRIMARY KEY(pg_code))"
    EXECUTE IMMEDIATE "CREATE TABLE customer (
        cu_code CHAR(10) NOT NULL,
        cu_name VARCHAR(80) NOT NULL,
        cu_address VARCHAR(255),
        cu_city VARCHAR(80),
        cu_state CHAR(2),
        cu_country VARCHAR(80),
        cu_postcode CHAR(10),
        CONSTRAINT pk_customer_1 PRIMARY KEY(cu_code))"
    EXECUTE IMMEDIATE "CREATE TABLE order_header (
        oh_code CHAR(10) NOT NULL,
        oh_cu_code CHAR(10) NOT NULL,
        oh_order_date DATE NOT NULL,
        oh_upload DATETIME YEAR TO SECOND,
        oh_order_value DECIMAL(11,2),
        oh_delivery_name VARCHAR(80),
        oh_delivery_address VARCHAR(255),
        oh_delivery_city VARCHAR(80),
        oh_delivery_state CHAR(2),
        oh_delivery_country VARCHAR(80),
        oh_delivery_postcode CHAR(10),
        CONSTRAINT pk_order_header_1 PRIMARY KEY(oh_code),
        CONSTRAINT fk_order_header_customer_1 FOREIGN KEY(oh_cu_code)
            REFERENCES customer(cu_code))"
    EXECUTE IMMEDIATE "CREATE TABLE order_line (
        ol_oh_code CHAR(10) NOT NULL,
        ol_idx INTEGER NOT NULL,
        ol_pr_code CHAR(8) NOT NULL,
        ol_qty DECIMAL(11,2) NOT NULL,
        ol_price DECIMAL(11,2) NOT NULL,
        ol_line_value DECIMAL(11,2) NOT NULL,
        CONSTRAINT pk_order_line_1 PRIMARY KEY(ol_oh_code, ol_idx),
        CONSTRAINT fk_order_line_order_header_1 FOREIGN KEY(ol_oh_code)
            REFERENCES order_header(oh_code),
        CONSTRAINT fk_order_line_product_1 FOREIGN KEY(ol_pr_code)
            REFERENCES product(pr_code))"
    EXECUTE IMMEDIATE "CREATE TABLE settings (
        url VARCHAR(80),
        device_prefix CHAR(2),
        next_customer INTEGER,
        next_order INTEGER)"

END FUNCTION



#+ Add indexes for all tables.
FUNCTION db_add_indexes()
    WHENEVER ERROR STOP

    EXECUTE IMMEDIATE "CREATE INDEX idx_product_1 ON product(pr_desc, pr_code)"
    EXECUTE IMMEDIATE "CREATE INDEX idx_product_2 ON product(pr_pg_code, pr_code)"
    EXECUTE IMMEDIATE "CREATE INDEX idx_product_group_1 ON product_group(pg_desc, pg_code)"
    EXECUTE IMMEDIATE "CREATE INDEX idx_customer_1 ON customer(cu_name, cu_code)"

END FUNCTION
