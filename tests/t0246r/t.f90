program t
  call s
end program t

!sms$ignore begin
subroutine s
  print '(a)','hello'
end subroutine s
!sms$ignore end
