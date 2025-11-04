; Manual LLVM IR to test LICM
define void @manual_test(i32 %n) {
entry:
  br label %loop

loop:
  %i = phi i32 [0, %entry], [%i_next, %loop]
  %a = add i32 5, 10          ; loop-invariant
  %c = add i32 %i, %a
  %i_next = add i32 %i, 1
  %cond = icmp slt i32 %i_next, %n
  br i1 %cond, label %loop, label %end

end:
  ret void
}
