; ModuleID = 'test_licm_params.ll'
source_filename = "test_licm_params.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_with_params(i32 noundef %0, ptr noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  br label %5

5:                                                ; preds = %7, %4
  %.0 = phi i32 [ 0, %4 ], [ %11, %7 ]
  %6 = icmp slt i32 %.0, %0
  br i1 %6, label %7, label %12

7:                                                ; preds = %5
  %8 = add nsw i32 %2, %3
  %9 = sext i32 %.0 to i64
  %10 = getelementptr inbounds i32, ptr %1, i64 %9
  store i32 %8, ptr %10, align 4
  %11 = add nsw i32 %.0, 1
  br label %5, !llvm.loop !6

12:                                               ; preds = %5
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca [100 x i32], align 4
  %2 = getelementptr inbounds [100 x i32], ptr %1, i64 0, i64 0
  call void @test_with_params(i32 noundef 10, ptr noundef %2, i32 noundef 5, i32 noundef 3)
  ret i32 0
}

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Homebrew clang version 21.1.3"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
