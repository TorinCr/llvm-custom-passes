; ModuleID = 'test_derived_phi_ssa.ll'
source_filename = "test_derived_phi.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_derived_phi_explicit(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 0, %2 ], [ %8, %5 ]
  %.0.ive.mul = mul i32 %.01, 4
  %.0.ive = add i32 0, %.0.ive.mul
  %4 = icmp slt i32 %.01, %0
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.0.ive to i64
  %7 = getelementptr inbounds i32, ptr %1, i64 %6
  store i32 %.01, ptr %7, align 4
  %8 = add nsw i32 %.01, 1
  %9 = add nsw i32 %.0.ive, 4
  br label %3, !llvm.loop !6

10:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_multiple_derived_phi(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.02 = phi i32 [ 0, %2 ], [ %10, %5 ]
  %.0.ive.mul = mul i32 %.02, 1
  %.0.ive = add i32 5, %.0.ive.mul
  %.01.ive.mul = mul i32 %.02, 3
  %.01.ive = add i32 10, %.01.ive.mul
  %.03.ive.mul = mul i32 %.02, 2
  %.03.ive = add i32 0, %.03.ive.mul
  %4 = icmp slt i32 %.02, %0
  br i1 %4, label %5, label %14

5:                                                ; preds = %3
  %6 = add nsw i32 %.03.ive, %.01.ive
  %7 = add nsw i32 %6, %.0.ive
  %8 = sext i32 %.02 to i64
  %9 = getelementptr inbounds i32, ptr %1, i64 %8
  store i32 %7, ptr %9, align 4
  %10 = add nsw i32 %.02, 1
  %11 = add nsw i32 %.03.ive, 2
  %12 = add nsw i32 %.01.ive, 3
  %13 = add nsw i32 %.0.ive, 1
  br label %3, !llvm.loop !8

14:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_derived_with_offset(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 0, %2 ], [ %8, %5 ]
  %.0.ive.mul = mul i32 %.01, 1
  %.0.ive = add i32 100, %.0.ive.mul
  %4 = icmp slt i32 %.01, %0
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %1, i64 %6
  store i32 %.0.ive, ptr %7, align 4
  %8 = add nsw i32 %.01, 1
  %9 = add nsw i32 %.0.ive, 1
  br label %3, !llvm.loop !9

10:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca [1000 x i32], align 4
  %2 = getelementptr inbounds [1000 x i32], ptr %1, i64 0, i64 0
  call void @test_derived_phi_explicit(i32 noundef 10, ptr noundef %2)
  %3 = getelementptr inbounds [1000 x i32], ptr %1, i64 0, i64 0
  call void @test_multiple_derived_phi(i32 noundef 10, ptr noundef %3)
  %4 = getelementptr inbounds [1000 x i32], ptr %1, i64 0, i64 0
  call void @test_derived_with_offset(i32 noundef 10, ptr noundef %4)
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
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
