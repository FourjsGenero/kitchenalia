import util

schema kitchenalia

type customer_type record like customer.*
define m_rec customer_type
define m_add_flag boolean



function add()
    initialize m_rec.* to null
    let m_add_flag = true
    -- TODO add customer number generation
    -- TODO add defaults
    let m_rec.cu_code = "CM", util.Math.rand(10000) using "&&&&&&"
    if edit(true) then
        insert into customer values (m_rec.*)
    else 
        initialize m_rec.* to null
    end if
    
    return m_rec.cu_code
end function



function update()
    let m_add_flag = false
    if edit(false) then
        update customer
        set customer.* = m_rec.*
        where cu_code = m_rec.cu_code
    end if
end function



private function edit(l_add_flag)
define l_add_flag boolean
define w ui.Window

    open window customer_grid with form "customer_grid" attributes(type=popup)
    let w = ui.Window.getCurrent()
    if l_add_flag then
        call w.setText("New Customer")
    else
        call w.setText("Edit Customer")
    end if
    input by name m_rec.* attributes(without defaults=true)
        before input
            call dialog.setFieldActive("cu_code", l_add_flag)
    end input
    -- TODO add validation

    close window customer_grid
    if int_flag then
        let int_flag = 0
        return false
    else
        return true
    end if
end function
