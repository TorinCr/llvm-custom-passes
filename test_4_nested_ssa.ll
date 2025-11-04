; ModuleID = 'test_4_nested.ll'
source_filename = "test_4_nested.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @nested_simple(i32 noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  br label %4

4:                                                ; preds = %18, %3
  %.01 = phi i32 [ 0, %3 ], [ %19, %18 ]
  %5 = icmp slt i32 %.01, %0
  br i1 %5, label %6, label %20

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %15, %6
  %.0 = phi i32 [ 0, %6 ], [ %16, %15 ]
  %8 = icmp slt i32 %.0, %1
  br i1 %8, label %9, label %17

9:                                                ; preds = %7
  %10 = add nsw i32 %.01, %.0
  %11 = mul nsw i32 %.01, %1
  %12 = add nsw i32 %11, %.0
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  store i32 %10, ptr %14, align 4
  br label %15

15:                                               ; preds = %9
  %16 = add nsw i32 %.0, 1
  br label %7, !llvm.loop !6

17:                                               ; preds = %7
  br label %18

18:                                               ; preds = %17
  %19 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !8

20:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @nested_derived_iv(i32 noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  br label %4

4:                                                ; preds = %19, %3
  %.01 = phi i32 [ 0, %3 ], [ %20, %19 ]
  %5 = icmp slt i32 %.01, %0
  br i1 %5, label %6, label %21

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %16, %6
  %.0 = phi i32 [ 0, %6 ], [ %17, %16 ]
  %8 = icmp slt i32 %.0, %1
  br i1 %8, label %9, label %18

9:                                                ; preds = %7
  %10 = mul nsw i32 %.0, 4
  %11 = add nsw i32 %.01, %.0
  %12 = mul nsw i32 %.01, %1
  %13 = add nsw i32 %12, %10
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i32, ptr %2, i64 %14
  store i32 %11, ptr %15, align 4
  br label %16

16:                                               ; preds = %9
  %17 = add nsw i32 %.0, 1
  br label %7, !llvm.loop !9

18:                                               ; preds = %7
  br label %19

19:                                               ; preds = %18
  %20 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !10

21:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @nested_invariant(i32 noundef %0, i32 noundef %1, ptr noundef %2, i32 noundef %3, i32 noundef %4) #0 {
  br label %6

6:                                                ; preds = %23, %5
  %.01 = phi i32 [ 0, %5 ], [ %24, %23 ]
  %7 = icmp slt i32 %.01, %0
  br i1 %7, label %8, label %25

8:                                                ; preds = %6
  %9 = mul nsw i32 %3, %4
  br label %10

10:                                               ; preds = %20, %8
  %.0 = phi i32 [ 0, %8 ], [ %21, %20 ]
  %11 = icmp slt i32 %.0, %1
  br i1 %11, label %12, label %22

12:                                               ; preds = %10
  %13 = add nsw i32 %9, 10
  %14 = add nsw i32 %13, %.01
  %15 = add nsw i32 %14, %.0
  %16 = mul nsw i32 %.01, %1
  %17 = add nsw i32 %16, %.0
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds i32, ptr %2, i64 %18
  store i32 %15, ptr %19, align 4
  br label %20

20:                                               ; preds = %12
  %21 = add nsw i32 %.0, 1
  br label %10, !llvm.loop !11

22:                                               ; preds = %10
  br label %23

23:                                               ; preds = %22
  %24 = add nsw i32 %.01, 1
  br label %6, !llvm.loop !12

25:                                               ; preds = %6
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @triple_nested(i32 noundef %0, ptr noundef %1) #0 {
  br label %3

3:                                                ; preds = %27, %2
  %.02 = phi i32 [ 0, %2 ], [ %28, %27 ]
  %4 = icmp slt i32 %.02, %0
  br i1 %4, label %5, label %29

5:                                                ; preds = %3
  br label %6

6:                                                ; preds = %24, %5
  %.01 = phi i32 [ 0, %5 ], [ %25, %24 ]
  %7 = icmp slt i32 %.01, %0
  br i1 %7, label %8, label %26

8:                                                ; preds = %6
  br label %9

9:                                                ; preds = %21, %8
  %.0 = phi i32 [ 0, %8 ], [ %22, %21 ]
  %10 = icmp slt i32 %.0, %0
  br i1 %10, label %11, label %23

11:                                               ; preds = %9
  %12 = add nsw i32 %.02, %.01
  %13 = add nsw i32 %12, %.0
  %14 = mul nsw i32 %.02, %0
  %15 = mul nsw i32 %14, %0
  %16 = mul nsw i32 %.01, %0
  %17 = add nsw i32 %15, %16
  %18 = add nsw i32 %17, %.0
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds i32, ptr %1, i64 %19
  store i32 %13, ptr %20, align 4
  br label %21

21:                                               ; preds = %11
  %22 = add nsw i32 %.0, 1
  br label %9, !llvm.loop !13

23:                                               ; preds = %9
  br label %24

24:                                               ; preds = %23
  %25 = add nsw i32 %.01, 1
  br label %6, !llvm.loop !14

26:                                               ; preds = %6
  br label %27

27:                                               ; preds = %26
  %28 = add nsw i32 %.02, 1
  br label %3, !llvm.loop !15

29:                                               ; preds = %3
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
