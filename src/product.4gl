schema kitchenalia

function desc_get(l_pr_code)
define l_pr_code like product.pr_code
define l_pr_desc like product.pr_desc

    select pr_desc
    into l_pr_desc
    from product
    where pr_code = l_pr_code
    return l_pr_desc
end function

function thumbnail_get(l_pi_pr_code)
define l_pi_pr_code like product_image.pi_pr_code
define l_pi_filename like product_image.pi_filename

    declare thumbnail_curs cursor from "select pi_filename from product_image where pi_pr_code = ? order by pi_idx"
    open thumbnail_curs using l_pi_pr_code
    fetch thumbnail_curs into l_pi_filename
    return l_pi_filename
end function