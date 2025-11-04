; ModuleID = 'test_4_nested.ll'
source_filename = "test_4_nested.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: nofree norecurse nosync nounwind ssp memory(argmem: write) uwtable(sync)
define void @nested_simple(i32 noundef %0, i32 noundef %1, ptr noundef writeonly captures(none) %2) local_unnamed_addr #0 {
  %4 = icmp sgt i32 %0, 0
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %6 = icmp sgt i32 %1, 0
  %7 = zext i32 %1 to i64
  %8 = zext nneg i32 %0 to i64
  %9 = zext nneg i32 %1 to i64
  br label %10

10:                                               ; preds = %16, %5
  %11 = phi i64 [ 0, %5 ], [ %17, %16 ]
  br i1 %6, label %12, label %16

12:                                               ; preds = %10
  %13 = mul nuw nsw i64 %11, %7
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  br label %19

.loopexit1:                                       ; preds = %16
  br label %15

15:                                               ; preds = %.loopexit1, %3
  ret void

.loopexit:                                        ; preds = %19
  br label %16

16:                                               ; preds = %.loopexit, %10
  %17 = add nuw nsw i64 %11, 1
  %18 = icmp eq i64 %17, %8
  br i1 %18, label %.loopexit1, label %10, !llvm.loop !6

19:                                               ; preds = %19, %12
  %20 = phi i64 [ 0, %12 ], [ %24, %19 ]
  %21 = add nuw nsw i64 %20, %11
  %22 = getelementptr inbounds i32, ptr %14, i64 %20
  %23 = trunc nuw i64 %21 to i32
  store i32 %23, ptr %22, align 4, !tbaa !9
  %24 = add nuw nsw i64 %20, 1
  %25 = icmp eq i64 %24, %9
  br i1 %25, label %.loopexit, label %19, !llvm.loop !13
}

; Function Attrs: nofree norecurse nosync nounwind ssp memory(argmem: write) uwtable(sync)
define void @nested_derived_iv(i32 noundef %0, i32 noundef %1, ptr noundef writeonly captures(none) %2) local_unnamed_addr #0 {
  %4 = icmp sgt i32 %0, 0
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %6 = icmp sgt i32 %1, 0
  %7 = sext i32 %1 to i64
  %8 = zext nneg i32 %0 to i64
  %9 = zext nneg i32 %1 to i64
  br label %10

10:                                               ; preds = %16, %5
  %11 = phi i64 [ 0, %5 ], [ %17, %16 ]
  br i1 %6, label %12, label %16

12:                                               ; preds = %10
  %13 = mul nuw nsw i64 %11, %7
  %14 = getelementptr i32, ptr %2, i64 %13
  br label %19

.loopexit1:                                       ; preds = %16
  br label %15

15:                                               ; preds = %.loopexit1, %3
  ret void

.loopexit:                                        ; preds = %19
  br label %16

16:                                               ; preds = %.loopexit, %10
  %17 = add nuw nsw i64 %11, 1
  %18 = icmp eq i64 %17, %8
  br i1 %18, label %.loopexit1, label %10, !llvm.loop !14

19:                                               ; preds = %19, %12
  %20 = phi i64 [ 0, %12 ], [ %25, %19 ]
  %21 = add nuw nsw i64 %20, %11
  %22 = shl nsw i64 %20, 4
  %23 = getelementptr i8, ptr %14, i64 %22
  %24 = trunc nuw i64 %21 to i32
  store i32 %24, ptr %23, align 4, !tbaa !9
  %25 = add nuw nsw i64 %20, 1
  %26 = icmp eq i64 %25, %9
  br i1 %26, label %.loopexit, label %19, !llvm.loop !15
}

; Function Attrs: nofree norecurse nosync nounwind ssp memory(argmem: write) uwtable(sync)
define void @nested_invariant(i32 noundef %0, i32 noundef %1, ptr noundef writeonly captures(none) %2, i32 noundef %3, i32 noundef %4) local_unnamed_addr #0 {
  %6 = icmp sgt i32 %0, 0
  br i1 %6, label %7, label %14

7:                                                ; preds = %5
  %8 = mul nsw i32 %4, %3
  %9 = icmp sgt i32 %1, 0
  %10 = add nsw i32 %8, 10
  %11 = zext i32 %10 to i64
  %12 = zext nneg i32 %0 to i64
  %13 = zext nneg i32 %1 to i64
  br label %15

.loopexit1:                                       ; preds = %23
  br label %14

14:                                               ; preds = %.loopexit1, %5
  ret void

15:                                               ; preds = %23, %7
  %16 = phi i64 [ 0, %7 ], [ %24, %23 ]
  br i1 %9, label %17, label %23

17:                                               ; preds = %15
  %18 = add nuw i64 %16, %11
  %19 = trunc i64 %16 to i32
  %20 = mul i32 %1, %19
  %21 = zext i32 %20 to i64
  %22 = getelementptr inbounds i32, ptr %2, i64 %21
  br label %26

.loopexit:                                        ; preds = %26
  br label %23

23:                                               ; preds = %.loopexit, %15
  %24 = add nuw nsw i64 %16, 1
  %25 = icmp eq i64 %24, %12
  br i1 %25, label %.loopexit1, label %15, !llvm.loop !16

26:                                               ; preds = %26, %17
  %27 = phi i64 [ 0, %17 ], [ %31, %26 ]
  %28 = add i64 %18, %27
  %29 = getelementptr inbounds i32, ptr %22, i64 %27
  %30 = trunc i64 %28 to i32
  store i32 %30, ptr %29, align 4, !tbaa !9
  %31 = add nuw nsw i64 %27, 1
  %32 = icmp eq i64 %31, %13
  br i1 %32, label %.loopexit, label %26, !llvm.loop !17
}

; Function Attrs: nofree norecurse nosync nounwind ssp memory(argmem: write) uwtable(sync)
define void @triple_nested(i32 noundef %0, ptr noundef writeonly captures(none) %1) local_unnamed_addr #0 {
  %3 = icmp sgt i32 %0, 0
  br i1 %3, label %4, label %12

4:                                                ; preds = %2
  %5 = zext nneg i32 %0 to i64
  %6 = zext nneg i32 %0 to i64
  %7 = zext nneg i32 %0 to i64
  br label %8

8:                                                ; preds = %21, %4
  %9 = phi i64 [ 0, %4 ], [ %22, %21 ]
  %10 = trunc i64 %9 to i32
  %11 = mul i32 %0, %10
  br label %13

.loopexit:                                        ; preds = %21
  br label %12

12:                                               ; preds = %.loopexit, %2
  ret void

13:                                               ; preds = %24, %8
  %14 = phi i64 [ 0, %8 ], [ %25, %24 ]
  %15 = add nuw nsw i64 %14, %9
  %16 = trunc i64 %14 to i32
  %17 = add i32 %11, %16
  %18 = mul i32 %17, %0
  %19 = sext i32 %18 to i64
  %20 = getelementptr i32, ptr %1, i64 %19
  br label %27

21:                                               ; preds = %24
  %22 = add nuw nsw i64 %9, 1
  %23 = icmp eq i64 %22, %5
  br i1 %23, label %.loopexit, label %8, !llvm.loop !18

24:                                               ; preds = %27
  %25 = add nuw nsw i64 %14, 1
  %26 = icmp eq i64 %25, %6
  br i1 %26, label %21, label %13, !llvm.loop !19

27:                                               ; preds = %27, %13
  %28 = phi i64 [ 0, %13 ], [ %32, %27 ]
  %29 = add nuw nsw i64 %15, %28
  %30 = getelementptr i32, ptr %20, i64 %28
  %31 = trunc nsw i64 %29 to i32
  store i32 %31, ptr %30, align 4, !tbaa !9
  %32 = add nuw nsw i64 %28, 1
  %33 = icmp eq i64 %32, %7
  br i1 %33, label %24, label %27, !llvm.loop !20
}

attributes #0 = { nofree norecurse nosync nounwind ssp memory(argmem: write) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Homebrew clang version 21.1.3"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{!"llvm.loop.unroll.disable"}
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C/C++ TBAA"}
!13 = distinct !{!13, !7, !8}
!14 = distinct !{!14, !7, !8}
!15 = distinct !{!15, !7, !8}
!16 = distinct !{!16, !7, !8}
!17 = distinct !{!17, !7, !8}
!18 = distinct !{!18, !7, !8}
!19 = distinct !{!19, !7, !8}
!20 = distinct !{!20, !7, !8}
