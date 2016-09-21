import fgl gc_line
import fgl gc_column
import fgl gc_pie
import fgl settings
import com
import util
import fgl product
import fgl customer

schema kitchenalia

function line_product_sales(l_pr_code)
define l_pr_code like product.pr_code
define l_arr dynamic array of record
    month integer,
    value like order_line.ol_line_value
end record
define g gc_line.line_rec
define wc string

define l_url string
define req com.HttpRequest
define resp com.HttpResponse
define s string
define j util.JSONObject
define j_resp record 
    count FLOAT,
    results DYNAMIC ARRAY OF RECORD
        year FLOAT,
        month FLOAT,
        total_lines FLOAT,
        total_qty FLOAT,
        total_value FLOAT
    END RECORD
END RECORD
define i integer


    let l_url = sfmt("%1/ws/r/kitchenalia/get_time_analysis?pr_code=%2", settings.m_rec.url, l_pr_code)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)

     open window chart with form "chart_line" attributes(style="dialog")
     IF NOT gc_line.is_loaded("formonly.wc",15) THEN
        CALL show_error("Problem loading Web Component",true)
        CLOSE WINDOW chart
        RETURN false, ""
    END IF

    INITIALIZE g.* TO NULL
    
    call window_size() returning g.width, g.height
    let g.chart_area.left = g.width * 0.05
    let g.chart_area.top = g.height * 0.05
    let g.chart_area.height = g.height * 0.9
    let g.chart_area.width = g.width * 0.9

    LET g.colors[1] = "#3366CC"
    LET g.colors[2] = "#DC3912"
    LET g.colors[3] = "#FF9900"
    LET g.colors[4] = "#109618"
    LET g.colors[5] = "#990099"
    LET g.colors[6] = "#3B3EAC"
    LET g.colors[7] = "#0099C6"
    LET g.colors[8] = "#DD4477"
    LET g.colors[9] = "#66AA00"
    LET g.colors[10] = "#B82E2E"
    LET g.colors[11] = "#316395"
    LET g.colors[12] = "#994499"
    LET g.colors[13] = "#22AA99"
    LET g.colors[14] = "#AAAA11"
    LET g.colors[15] = "#6633CC"
    LET g.colors[16] = "#E67300"
    LET g.colors[17] = "#8B0707"
    LET g.colors[18] = "#329262"
    LET g.colors[19] = "#5574A6"
    LET g.colors[20] = "#3B3EAC"

    LET g.line_dash_style[1] = 1
    LET g.line_dash_style[2] = 0

    let g.title = "Last 12 Months Sales of ", product.desc_get(l_pr_code)

    for i = 1 to 12
        let l_arr[i].month = i
        let l_arr[i].value = 0
    end for
    for i = 1 to j_resp.results.getLength()
        let l_arr[j_resp.results[i].month].value = j_resp.results[i].total_value
    end for
    
    LET g.data_col_count = 2
    LET g.data_column[1].label = "Month"
    LET g.data_column[2].label ="Sales"
    LET g.data_column[1].type = "string"
    LET g.data_column[2].type = "number"
    CALL map_array_to_data(base.TypeInfo.create(l_arr), g.data, "month,value")
    LET g.data_row_count = l_arr.getLength()
    
    INPUT BY NAME wc ATTRIBUTES(WITHOUT DEFAULTS=TRUE, CANCEL=FALSE) 
        BEFORE INPUT
            
            CALL gc_line.draw("formonly.wc", g.*)
            
        ON ACTION close
            EXIT INPUT
    END INPUT
    close window chart
    return true, ""

end function



function line_customer_sales(l_cu_code)
define l_cu_code like customer.cu_code
define l_arr dynamic array of record
    month integer,
    value like order_line.ol_line_value
end record
define g gc_line.line_rec
define wc string

define l_url string
define req com.HttpRequest
define resp com.HttpResponse
define s string
define j util.JSONObject
define j_resp record 
    count FLOAT,
    results DYNAMIC ARRAY OF RECORD
        year FLOAT,
        month FLOAT,
        total_lines FLOAT,
        total_qty FLOAT,
        total_value FLOAT
    END RECORD
END RECORD
define i integer


    let l_url = sfmt("%1/ws/r/kitchenalia/get_time_analysis?cu_code=%2", settings.m_rec.url, l_cu_code)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)

     open window chart with form "chart_line" attributes(style="dialog")
     IF NOT gc_line.is_loaded("formonly.wc",15) THEN
        CALL show_error("Problem loading Web Component",true)
        CLOSE WINDOW chart
        RETURN false, ""
    END IF

    INITIALIZE g.* TO NULL
    
    call window_size() returning g.width, g.height
    let g.chart_area.left = g.width * 0.05
    let g.chart_area.top = g.height * 0.05
    let g.chart_area.height = g.height * 0.9
    let g.chart_area.width = g.width * 0.9

    LET g.colors[1] = "#3366CC"
    LET g.colors[2] = "#DC3912"
    LET g.colors[3] = "#FF9900"
    LET g.colors[4] = "#109618"
    LET g.colors[5] = "#990099"
    LET g.colors[6] = "#3B3EAC"
    LET g.colors[7] = "#0099C6"
    LET g.colors[8] = "#DD4477"
    LET g.colors[9] = "#66AA00"
    LET g.colors[10] = "#B82E2E"
    LET g.colors[11] = "#316395"
    LET g.colors[12] = "#994499"
    LET g.colors[13] = "#22AA99"
    LET g.colors[14] = "#AAAA11"
    LET g.colors[15] = "#6633CC"
    LET g.colors[16] = "#E67300"
    LET g.colors[17] = "#8B0707"
    LET g.colors[18] = "#329262"
    LET g.colors[19] = "#5574A6"
    LET g.colors[20] = "#3B3EAC"

    LET g.line_dash_style[1] = 1
    LET g.line_dash_style[2] = 0

    let g.title = "Last 12 Months Sales History for ", customer.name_get(l_cu_code)

    for i = 1 to 12
        let l_arr[i].month = i
        let l_arr[i].value = 0
    end for
    for i = 1 to j_resp.results.getLength()
        let l_arr[j_resp.results[i].month].value = j_resp.results[i].total_value
    end for
    
    LET g.data_col_count = 2
    LET g.data_column[1].label = "Month"
    LET g.data_column[2].label ="Sales"
    LET g.data_column[1].type = "string"
    LET g.data_column[2].type = "number"
    CALL map_array_to_data(base.TypeInfo.create(l_arr), g.data, "month,value")
    LET g.data_row_count = l_arr.getLength()
    
    INPUT BY NAME wc ATTRIBUTES(WITHOUT DEFAULTS=TRUE, CANCEL=FALSE) 
        BEFORE INPUT
            
            CALL gc_line.draw("formonly.wc", g.*)
            
        ON ACTION close
            EXIT INPUT
    END INPUT
    close window chart
    return true, ""

end function



function pie_customer_sales(l_cu_code)
define l_cu_code like customer.cu_code
define l_arr dynamic array of record
    pg_code like product_group.pg_code,
    value like order_line.ol_line_value
end record
define g gc_pie.pie_rec
define wc string

define l_url string
define req com.HttpRequest
define resp com.HttpResponse
define s string
define j util.JSONObject
define j_resp record 
    count FLOAT,
    results DYNAMIC ARRAY OF RECORD
        pg_code STRING,
        total_value FLOAT
    END RECORD
END RECORD
define i integer


    let l_url = sfmt("%1/ws/r/kitchenalia/get_group_analysis?cu_code=%2", settings.m_rec.url, l_cu_code)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)

     open window chart with form "chart_pie" attributes(style="dialog")
     IF NOT gc_line.is_loaded("formonly.wc",15) THEN
        CALL show_error("Problem loading Web Component",true)
        CLOSE WINDOW chart
        RETURN false, ""
    END IF

    INITIALIZE g.* TO NULL
    
    call window_size() returning g.width, g.height
    let g.chart_area.left = g.width * 0.05
    let g.chart_area.top = g.height * 0.05
    let g.chart_area.height = g.height * 0.9
    let g.chart_area.width = g.width * 0.9

    LET g.colors[1] = "#3366CC"
    LET g.colors[2] = "#DC3912"
    LET g.colors[3] = "#FF9900"
    LET g.colors[4] = "#109618"
    LET g.colors[5] = "#990099"
    LET g.colors[6] = "#3B3EAC"
    LET g.colors[7] = "#0099C6"
    LET g.colors[8] = "#DD4477"
    LET g.colors[9] = "#66AA00"
    LET g.colors[10] = "#B82E2E"
    LET g.colors[11] = "#316395"
    LET g.colors[12] = "#994499"
    LET g.colors[13] = "#22AA99"
    LET g.colors[14] = "#AAAA11"
    LET g.colors[15] = "#6633CC"
    LET g.colors[16] = "#E67300"
    LET g.colors[17] = "#8B0707"
    LET g.colors[18] = "#329262"
    LET g.colors[19] = "#5574A6"
    LET g.colors[20] = "#3B3EAC"

    let g.title = "Last 12 Month Sales by Product Group for ", customer.name_get(l_cu_code)

    for i = 1 to j_resp.results.getLength()
        let l_arr[i].pg_code = j_resp.results[i].pg_code
        let l_arr[i].value = j_resp.results[i].total_value
    end for
    
    LET g.data_col_count = 2
    LET g.data_column[1].label = "Product Group"
    LET g.data_column[2].label ="Sales"
    LET g.data_column[1].type = "string"
    LET g.data_column[2].type = "number"
    CALL map_array_to_data(base.TypeInfo.create(l_arr), g.data, "pg_code,value")
    LET g.data_row_count = l_arr.getLength()
    
    INPUT BY NAME wc ATTRIBUTES(WITHOUT DEFAULTS=TRUE, CANCEL=FALSE) 
        BEFORE INPUT
            
            CALL gc_pie.draw("formonly.wc", g.*)
            
        ON ACTION close
            EXIT INPUT
    END INPUT
    close window chart
    return true, ""

end function



function stacked_customer_group_sales(l_cu_code)
define l_cu_code like customer.cu_code
define l_arr dynamic array of record
    month integer,
    pg1_value like order_line.ol_line_value,
    pg2_value like order_line.ol_line_value,
    pg3_value like order_line.ol_line_value,
    pg4_value like order_line.ol_line_value,
    pg5_value like order_line.ol_line_value,
    pg6_value like order_line.ol_line_value,
    pg7_value like order_line.ol_line_value
end record
define g gc_column.column_rec
define wc string

define l_url string
define req com.HttpRequest
define resp com.HttpResponse
define s string
define j util.JSONObject
define j_resp record 
    count FLOAT,
    results DYNAMIC ARRAY OF RECORD
        oh_year FLOAT,
        oh_month FLOAT,
        pg_code STRING,
        total_value FLOAT
    END RECORD
END RECORD
define i integer


    let l_url = sfmt("%1/ws/r/kitchenalia/get_time_group_analysis?cu_code=%2", settings.m_rec.url, l_cu_code)
    
    let req = com.HttpRequest.create(l_url)
    call req.doRequest()
    let resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return false, resp.getStatusDescription()
    end if
    
    let s = resp.getTextResponse()
    let j = util.JSONObject.parse(s)
    call j.toFGL(j_resp)

     open window chart with form "chart_column" attributes(style="dialog")
     IF NOT gc_column.is_loaded("formonly.wc",15) THEN
        CALL show_error("Problem loading Web Component",true)
        CLOSE WINDOW chart
        RETURN false, ""
    END IF

    INITIALIZE g.* TO NULL
    
    call window_size() returning g.width, g.height
    let g.chart_area.left = g.width * 0.05
    let g.chart_area.top = g.height * 0.05
    let g.chart_area.height = g.height * 0.9
    let g.chart_area.width = g.width * 0.9

    LET g.colors[1] = "#3366CC"
    LET g.colors[2] = "#DC3912"
    LET g.colors[3] = "#FF9900"
    LET g.colors[4] = "#109618"
    LET g.colors[5] = "#990099"
    LET g.colors[6] = "#3B3EAC"
    LET g.colors[7] = "#0099C6"
    LET g.colors[8] = "#DD4477"
    LET g.colors[9] = "#66AA00"
    LET g.colors[10] = "#B82E2E"
    LET g.colors[11] = "#316395"
    LET g.colors[12] = "#994499"
    LET g.colors[13] = "#22AA99"
    LET g.colors[14] = "#AAAA11"
    LET g.colors[15] = "#6633CC"
    LET g.colors[16] = "#E67300"
    LET g.colors[17] = "#8B0707"
    LET g.colors[18] = "#329262"
    LET g.colors[19] = "#5574A6"
    LET g.colors[20] = "#3B3EAC"

    let g.title = "Last 12 Months Sales History for ", customer.name_get(l_cu_code)
    let g.is_stacked = "true"

    for i = 1 to 12
        let l_arr[i].month = i
        let l_arr[i].pg1_value = 0
        let l_arr[i].pg2_value = 0
        let l_arr[i].pg3_value = 0
        let l_arr[i].pg4_value = 0
        let l_arr[i].pg5_value = 0
        let l_arr[i].pg6_value = 0
        let l_arr[i].pg7_value = 0
    end for
    display j.toString()
    for i = 1 to j_resp.results.getLength()
        display j_resp.results[i].oh_month, j_resp.results[i].pg_code
        case j_resp.results[i].pg_code.getCharAt(1)
            when 1 let l_arr[j_resp.results[i].oh_month].pg1_value =  l_arr[j_resp.results[i].oh_month].pg1_value + j_resp.results[i].total_value
            when 2 let l_arr[j_resp.results[i].oh_month].pg2_value =  l_arr[j_resp.results[i].oh_month].pg2_value + j_resp.results[i].total_value
            when 3 let l_arr[j_resp.results[i].oh_month].pg3_value =  l_arr[j_resp.results[i].oh_month].pg3_value + j_resp.results[i].total_value
            when 4 let l_arr[j_resp.results[i].oh_month].pg4_value =  l_arr[j_resp.results[i].oh_month].pg4_value + j_resp.results[i].total_value
            when 5 let l_arr[j_resp.results[i].oh_month].pg5_value =  l_arr[j_resp.results[i].oh_month].pg5_value + j_resp.results[i].total_value
            when 6 let l_arr[j_resp.results[i].oh_month].pg6_value =  l_arr[j_resp.results[i].oh_month].pg6_value + j_resp.results[i].total_value
            when 7 let l_arr[j_resp.results[i].oh_month].pg7_value =  l_arr[j_resp.results[i].oh_month].pg7_value + j_resp.results[i].total_value
        end case
    end for
    
    LET g.data_col_count = 8
    LET g.data_column[1].label = "Month"
    LET g.data_column[2].label = "Product Group (1*)"
    LET g.data_column[3].label = "Product Group (2*)"
    LET g.data_column[4].label = "Product Group (3*)"
    LET g.data_column[5].label = "Product Group (4*)"
    LET g.data_column[6].label = "Product Group (5*)"
    LET g.data_column[7].label = "Product Group (6*)"
    LET g.data_column[8].label = "Product Group (7*)"
    
    LET g.data_column[1].type = "string"
    LET g.data_column[2].type = "number"
    LET g.data_column[3].type = "number"
    LET g.data_column[4].type = "number"
    LET g.data_column[5].type = "number"
    LET g.data_column[6].type = "number"
    LET g.data_column[7].type = "number"
    LET g.data_column[8].type = "number"

    CALL map_array_to_data(base.TypeInfo.create(l_arr), g.data, "month,pg1_value,pg2_value,pg3_value,pg4_value,pg5_value,pg6_value,pg7_value)")
    LET g.data_row_count = l_arr.getLength()
    
    INPUT BY NAME wc ATTRIBUTES(WITHOUT DEFAULTS=TRUE, CANCEL=FALSE) 
        BEFORE INPUT
            
            CALL gc_column.draw("formonly.wc", g.*)
            
        ON ACTION close
            EXIT INPUT
    END INPUT
    close window chart
    return true, ""

end function




-- Take a 4gl array and map to data for passing to web component
-- Note: array is passed in via base.Typeinfo.create(array_name)
private function map_array_to_data(n, d,  column_list)
define n om.domnode
define d dynamic array with dimension 2 of string
define column_list string

define r om.domnode
define i,j integer
define tok base.stringtokenizer

    call d.clear()
    for i = 1 to n.getchildcount()
        let r = n.getchildbyindex(i)
        let j = 0
        let tok = base.stringtokenizer.create(column_list,",")
        while tok.hasmoretokens()
            let j = j + 1
            let d[i,j] = get_record_node(r,tok.nexttoken())
        end while
    end for
end function



private function get_record_node(r,c)
define r om.domnode
define nl om.nodelist
define f om.domnode
define c string

    let nl = r.selectbypath(sfmt("//Field[@name='%1']",c))
    if nl.getlength() != 1 then
        return null
    else
        let f = nl.item(1)
        return f.getattribute("value")
    end if
end function