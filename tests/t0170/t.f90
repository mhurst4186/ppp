program t
  character(len=4)::a,b
  character(len=5)::c(2)
  equivalence (a,c(1)),(b,c(2))
end program t