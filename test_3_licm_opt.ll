; ModuleID = 'test_3_licm_ssa.ll'
source_filename = "test_3_licm.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @simple_invariant(i32 noundef %0, ptr noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  br label %5

5:                                                ; preds = %12, %4
  %.0 = phi i32 [ 0, %4 ], [ %13, %12 ]
  %6 = icmp slt i32 %.0, %0
  br i1 %6, label %7, label %14

7:                                                ; preds = %5
  %8 = mul nsw i32 %2, %3
  %9 = add nsw i32 %8, %.0
  %10 = sext i32 %.0 to i64
  %11 = getelementptr inbounds i32, ptr %1, i64 %10
  store i32 %9, ptr %11, align 4
  br label %12

12:                                               ; preds = %7
  %13 = add nsw i32 %.0, 1
  br label %5, !llvm.loop !6

14:                                               ; preds = %5
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @multiple_invariants(i32 noundef %0, ptr noundef %1, i32 noundef %2, i32 noundef %3, i32 noundef %4) #0 {
  br label %6

6:                                                ; preds = %15, %5
  %.0 = phi i32 [ 0, %5 ], [ %16, %15 ]
  %7 = icmp slt i32 %.0, %0
  br i1 %7, label %8, label %17

8:                                                ; preds = %6
  %9 = add nsw i32 %2, %3
  %10 = mul nsw i32 %9, %4
  %11 = add nsw i32 %10, 100
  %12 = add nsw i32 %11, %.0
  %13 = sext i32 %.0 to i64
  %14 = getelementptr inbounds i32, ptr %1, i64 %13
  store i32 %12, ptr %14, align 4
  br label %15

15:                                               ; preds = %8
  %16 = add nsw i32 %.0, 1
  br label %6, !llvm.loop !8

17:                                               ; preds = %6
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @mixed_code(i32 noundef %0, ptr noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %13, %3
  %.0 = phi i32 [ 0, %3 ], [ %14, %13 ]
  %5 = icmp slt i32 %.0, %0
  br i1 %5, label %6, label %15

6:                                                ; preds = %4
  %7 = mul nsw i32 %2, 2
  %8 = add nsw i32 %7, 10
  %9 = mul nsw i32 %.0, 3
  %10 = add nsw i32 %8, %9
  %11 = sext i32 %.0 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 %10, ptr %12, align 4
  br label %13

13:                                               ; preds = %6
  %14 = add nsw i32 %.0, 1
  br label %4, !llvm.loop !9

15:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @nested_computation(i32 noundef %0, ptr noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  br label %5

5:                                                ; preds = %16, %4
  %.0 = phi i32 [ 0, %4 ], [ %17, %16 ]
  %6 = icmp slt i32 %.0, %0
  br i1 %6, label %7, label %18

7:                                                ; preds = %5
  %8 = add nsw i32 %2, %3
  %9 = sub nsw i32 %2, %3
  %10 = mul nsw i32 %8, %9
  %11 = add nsw i32 %10, 42
  %12 = mul nsw i32 %.0, %.0
  %13 = add nsw i32 %11, %12
  %14 = sext i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  store i32 %13, ptr %15, align 4
  br label %16

16:                                               ; preds = %7
  %17 = add nsw i32 %.0, 1
  br label %5, !llvm.loop !10

18:                                               ; preds = %5
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @no_side_effects(i32 noundef %0, ptr noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %13, %3
  %.0 = phi i32 [ 0, %3 ], [ %14, %13 ]
  %5 = icmp slt i32 %.0, %0
  br i1 %5, label %6, label %15

6:                                                ; preds = %4
  %7 = add nsw i32 %2, 5
  %8 = mul nsw i32 %7, 2
  %9 = sub nsw i32 %8, 3
  %10 = add nsw i32 %9, %.0
  %11 = sext i32 %.0 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 %10, ptr %12, align 4
  br label %13

13:                                               ; preds = %6
  %14 = add nsw i32 %.0, 1
  br label %4, !llvm.loop !11

15:                                               ; preds = %4
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
