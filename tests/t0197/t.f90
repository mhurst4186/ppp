program p
  print '(a)',f()
contains
  character(7) function f(i)
    integer i
    optional i
    if (present(i)) then
      f='present'
    else
      f='absent'
    endif
  end function f
end program p