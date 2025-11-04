; ModuleID = 'inputs/test_licm_manual.ll'
source_filename = "inputs/test_licm_manual.ll"

define void @manual_test(i32 %n) {
entry:
  %a = add i32 5, 10
  br label %loop

loop:                                             ; preds = %loop, %entry
  %i = phi i32 [ 0, %entry ], [ %i_next, %loop ]
  %c = add i32 %i, %a
  %i_next = add i32 %i, 1
  %cond = icmp slt i32 %i_next, %n
  br i1 %cond, label %loop, label %end

end:                                              ; preds = %loop
  ret void
}
