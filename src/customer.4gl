schema kitchenalia

function name_get(l_cu_code)
define l_cu_code like customer.cu_code
define l_cu_name like customer.cu_name

    select cu_name
    into l_cu_name
    from customer
    where cu_code = l_cu_code
    return l_cu_name
end function