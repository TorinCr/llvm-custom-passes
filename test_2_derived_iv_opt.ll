; ModuleID = 'test_2_derived_iv_ssa.ll'
source_filename = "test_2_derived_iv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @array_stride(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %9, %2
  %.0 = phi i32 [ 0, %2 ], [ %10, %9 ]
  %4 = icmp slt i32 %.0, %0
  br i1 %4, label %5, label %11

5:                                                ; preds = %3
  %6 = mul nsw i32 %.0, 4
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds i32, ptr %1, i64 %7
  store i32 %.0, ptr %8, align 4
  br label %9

9:                                                ; preds = %5
  %10 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !6

11:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @multiple_derived(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %15, %2
  %.0 = phi i32 [ 0, %2 ], [ %16, %15 ]
  %4 = icmp slt i32 %.0, %0
  br i1 %4, label %5, label %17

5:                                                ; preds = %3
  %6 = mul nsw i32 %.0, 4
  %7 = mul nsw i32 %.0, 2
  %8 = add nsw i32 10, %7
  %9 = mul nsw i32 %.0, 3
  %10 = add nsw i32 5, %9
  %11 = add nsw i32 %6, %8
  %12 = add nsw i32 %11, %10
  %13 = sext i32 %.0 to i64
  %14 = getelementptr inbounds i32, ptr %1, i64 %13
  store i32 %12, ptr %14, align 4
  br label %15

15:                                               ; preds = %5
  %16 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !8

17:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @offset_pattern(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %9, %2
  %.0 = phi i32 [ 0, %2 ], [ %10, %9 ]
  %4 = icmp slt i32 %.0, %0
  br i1 %4, label %5, label %11

5:                                                ; preds = %3
  %6 = add nsw i32 100, %.0
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds i32, ptr %1, i64 %7
  store i32 %.0, ptr %8, align 4
  br label %9

9:                                                ; preds = %5
  %10 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !9

11:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @negative_step(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %13, %2
  %.0 = phi i32 [ 0, %2 ], [ %14, %13 ]
  %4 = icmp slt i32 %.0, %0
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %6 = mul nsw i32 %.0, 2
  %7 = sub nsw i32 100, %6
  %8 = icmp sge i32 %7, 0
  br i1 %8, label %9, label %12

9:                                                ; preds = %5
  %10 = sext i32 %7 to i64
  %11 = getelementptr inbounds i32, ptr %1, i64 %10
  store i32 %.0, ptr %11, align 4
  br label %12

12:                                               ; preds = %9, %5
  br label %13

13:                                               ; preds = %12
  %14 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !10

15:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @complex_derived(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %11, %2
  %.0 = phi i32 [ 0, %2 ], [ %12, %11 ]
  %4 = icmp slt i32 %.0, %0
  br i1 %4, label %5, label %13

5:                                                ; preds = %3
  %6 = mul nsw i32 %.0, 8
  %7 = mul nsw i32 %.0, 5
  %8 = add nsw i32 50, %7
  %9 = sext i32 %6 to i64
  %10 = getelementptr inbounds i32, ptr %1, i64 %9
  store i32 %8, ptr %10, align 4
  br label %11

11:                                               ; preds = %5
  %12 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !11

13:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_explicit_increment(i32 noundef %0, ptr noundef %1) #0 {
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
  br label %3, !llvm.loop !12

10:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_three_derived(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.02 = phi i32 [ 0, %2 ], [ %10, %5 ]
  %.0.ive.mul = mul i32 %.02, 10
  %.0.ive = add i32 50, %.0.ive.mul
  %.01.ive.mul = mul i32 %.02, 5
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
  %12 = add nsw i32 %.01.ive, 5
  %13 = add nsw i32 %.0.ive, 10
  br label %3, !llvm.loop !13

14:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_backward_derived(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %9, %2
  %.01 = phi i32 [ 0, %2 ], [ %12, %9 ]
  %.0.ive.mul = mul i32 %.01, -2
  %.0.ive = add i32 100, %.0.ive.mul
  %4 = icmp slt i32 %.01, %0
  br i1 %4, label %5, label %7

5:                                                ; preds = %3
  %6 = icmp sgt i32 %.0.ive, 0
  br label %7

7:                                                ; preds = %5, %3
  %8 = phi i1 [ false, %3 ], [ %6, %5 ]
  br i1 %8, label %9, label %14

9:                                                ; preds = %7
  %10 = sext i32 %.01 to i64
  %11 = getelementptr inbounds i32, ptr %1, i64 %10
  store i32 %.0.ive, ptr %11, align 4
  %12 = add nsw i32 %.01, 1
  %13 = sub nsw i32 %.0.ive, 2
  br label %3, !llvm.loop !14

14:                                               ; preds = %7
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_mixed_steps(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.02 = phi i32 [ 0, %2 ], [ %9, %5 ]
  %.0.ive.mul = mul i32 %.02, 1
  %.0.ive = add i32 0, %.0.ive.mul
  %.01.ive.mul = mul i32 %.02, 8
  %.01.ive = add i32 0, %.01.ive.mul
  %4 = icmp slt i32 %.02, %0
  br i1 %4, label %5, label %12

5:                                                ; preds = %3
  %6 = add nsw i32 %.01.ive, %.0.ive
  %7 = sext i32 %.02 to i64
  %8 = getelementptr inbounds i32, ptr %1, i64 %7
  store i32 %6, ptr %8, align 4
  %9 = add nsw i32 %.02, 1
  %10 = add nsw i32 %.01.ive, 8
  %11 = add nsw i32 %.0.ive, 1
  br label %3, !llvm.loop !15

12:                                               ; preds = %3
  ret void
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
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
