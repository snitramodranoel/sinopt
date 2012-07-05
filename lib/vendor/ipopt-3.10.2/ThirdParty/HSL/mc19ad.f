* COPYRIGHT (c) 1967 AEA Technology
*######DATE 4 Oct 1992
C       Toolpack tool decs employed.
C       SAVE statement for COMMON FA01ED added.
C  EAT 21/6/93 EXTERNAL statement put in for block data on VAXs.
C
C
      DOUBLE PRECISION FUNCTION FA01AD(I)
C     .. Scalar Arguments ..
      INTEGER I
C     ..
C     .. Local Scalars ..
      DOUBLE PRECISION R,S
C     ..
C     .. Intrinsic Functions ..
      INTRINSIC DINT,MOD
C     ..
C     .. Common blocks ..
      COMMON /FA01ED/GL,GR
      DOUBLE PRECISION GL,GR
C     ..
C     .. Data block external statement
      EXTERNAL FA01FD
C     ..
C     .. Save statement ..
      SAVE /FA01ED/
C     ..
C     .. Executable Statements ..
      R = GR*9228907D0/65536D0
      S = DINT(R)
      GL = MOD(S+GL*9228907D0,65536D0)
      GR = R - S
      IF (I.GE.0) FA01AD = (GL+GR)/65536D0
      IF (I.LT.0) FA01AD = (GL+GR)/32768D0 - 1.D0
      GR = GR*65536D0
      RETURN

      END
      SUBROUTINE FA01BD(MAX,NRAND)
C     .. Scalar Arguments ..
      INTEGER MAX,NRAND
C     ..
C     .. External Functions ..
      DOUBLE PRECISION FA01AD
      EXTERNAL FA01AD
C     ..
C     .. Intrinsic Functions ..
      INTRINSIC DBLE,INT
C     ..
C     .. Executable Statements ..
      NRAND = INT(FA01AD(1)*DBLE(MAX)) + 1
      RETURN

      END
      SUBROUTINE FA01CD(IL,IR)
C     .. Scalar Arguments ..
      INTEGER IL,IR
C     ..
C     .. Common blocks ..
      COMMON /FA01ED/GL,GR
      DOUBLE PRECISION GL,GR
C     ..
C     .. Save statement ..
      SAVE /FA01ED/
C     ..
C     .. Executable Statements ..
      IL = GL
      IR = GR
      RETURN

      END
      SUBROUTINE FA01DD(IL,IR)
C     .. Scalar Arguments ..
      INTEGER IL,IR
C     ..
C     .. Common blocks ..
      COMMON /FA01ED/GL,GR
      DOUBLE PRECISION GL,GR
C     ..
C     .. Save statement ..
      SAVE /FA01ED/
C     ..
C     .. Executable Statements ..
      GL = IL
      GR = IR
      RETURN

      END
      BLOCK DATA FA01FD
C     .. Common blocks ..
      COMMON /FA01ED/GL,GR
      DOUBLE PRECISION GL,GR
C     ..
C     .. Save statement ..
      SAVE /FA01ED/
C     ..
C     .. Data statements ..
      DATA GL/21845D0/
      DATA GR/21845D0/
C     ..
C     .. Executable Statements ..
      END
C COPYRIGHT (c) 1977 AEA Technology.
C######DATE   09 MAR 1989
      SUBROUTINE MC19AD(N,NA,A,IRN,ICN,R,C,W)
      INTEGER   N,NA,IRN(*),ICN(*)
      DOUBLE PRECISION A(*)
C      IRN(K) GIVES ROW NUMBER OF ELEMENT IN A(K).
C      ICN(K) GIVES COL NUMBER OF ELEMENT IN A(K).
      REAL R(N),C(N),W(N,5)
C      R(I) IS USED TO RETURN LOG(SCALING FACTOR FOR ROW I).
C      C(J) IS USED TO RETURN LOG(SCALING FACTOR FOR COL J).
C      W(I,1),  W(I,2) HOLD ROW, COL NON-ZERO COUNTS.
C      W(J,3) HOLDS - COL J LOG DURING EXECUTION.
C      W(J,4) HOLDS 2-ITERATION CHANGE IN W(J,3).
C      W(I,5) IS USED TO SAVE AVERAGE ELEMENT LOG FOR ROW I.
      INTEGER LP,IFAIL
      COMMON/MC19BD/LP,IFAIL
      INTEGER I,I1,I2,ITER,J,K,L,MAXIT
      REAL E,E1,EM,Q,Q1,QM,S,S1,SM,SMIN,U,V
      EXTERNAL MC19CD
      INTRINSIC ALOG,DABS,FLOAT
      DATA MAXIT/100/,SMIN/0.1/
C MAXIT IS THE MAXIMAL PERMITTED NUMBER OF ITERATIONS
C     SMIN IS USED IN A CONVERGENCE TEST ON (RESIDUAL NORM)**2
C
C CHECK SCALAR DATA
      IFAIL=1
      IF(N.LT.1)GO TO 230
      IFAIL=2
      IFAIL=0
C
C     INITIALISE FOR ACCUMULATION OF SUMS AND PRODUCTS
      DO 5 I=1,N
      C(I)=0.
      R(I)=0.
5     CONTINUE
      DO 10 L=1,4
      DO 10 I=1,N
      W(I,L)=0.
10    CONTINUE
      IF(NA.LE.0)GO TO 250
      DO 30 K=1,NA
      U=DABS(A(K))
      IF(U.EQ.0.)GO TO 30
      U=ALOG(U)
      I1=IRN(K)
      I2=ICN(K)
      IF(I1.GE.1 .AND. I1.LE.N .AND. I2.GE.1 .AND. I2.LE.N)GO TO 20
      IF(LP.GT.0)WRITE(LP,15)K,I1,I2
15    FORMAT(20H MC19 ERROR. ELEMENT,I5,10H IS IN ROW,I5,
     1 8H AND COL,I5)
      IFAIL=3
      GO TO 30
C     COUNT ROW/COL NON-ZEROS, AND COMPUTE RHS VECTORS.
20    W(I1,1)=W(I1,1)+1.
      W(I2,2)=W(I2,2)+1.
      R(I1)=R(I1)+U
      W(I2,3)=W(I2,3)+U
   30 CONTINUE
      IF(IFAIL.EQ.3)GO TO 230
C
C     DIVIDE RHS BY DIAG MATRICES
      DO 70 I=1,N
      IF(W(I,1).EQ.0.)W(I,1)=1.
      R(I)=R(I)/W(I,1)
C     SAVE R(I) FOR USE AT END.
      W(I,5)=R(I)
      IF(W(I,2).EQ.0.)W(I,2)=1.
      W(I,3)=W(I,3)/W(I,2)
70    CONTINUE
      SM=SMIN*FLOAT(NA)
C     SWEEP TO COMPUTE INITIAL RESIDUAL VECTOR
      DO 80 K=1,NA
       IF(A(K).EQ.0.0 )GO TO 80
      I=IRN(K)
      J=ICN(K)
      R(I)=R(I)-W(J,3)/W(I,1)
   80 CONTINUE
C
C     INITIALISE ITERATION
      E=0.
      Q=1.
      S=0.
      DO 100 I=1,N
      S=S+W(I,1)*R(I)**2
100   CONTINUE
      IF(S.LE.SM)GO TO 186
C
C     ITERATION LOOP
      DO 185 ITER=1,MAXIT
C    SWEEP THROUGH MATRIX TO UPDATE RESIDUAL VECTOR
      DO 130 K=1,NA
      IF(A(K).EQ.0.)GO TO 130
      I=ICN(K)
      J=IRN(K)
      C(I)=C(I)+R(J)
  130 CONTINUE
      S1=S
      S=0.
      DO 140 I=1,N
      V=-C(I)/Q
      C(I)=V/W(I,2)
      S=S+V*C(I)
140   CONTINUE
      E1=E
      E=Q*S/S1
      Q=1.-E
      IF(S.LE.SM)E=0.
C     UPDATE RESIDUAL.
      DO 150 I=1,N
      R(I)=R(I)*E*W(I,1)
150   CONTINUE
      IF(S.LE.SM)GO TO 190
      EM=E*E1
C    SWEEP THROUGH MATRIX TO UPDATE RESIDUAL VECTOR
      DO 152 K=1,NA
      IF(A(K).EQ.0.0 ) GO TO 152
      I=IRN(K)
      J=ICN(K)
      R(I)=R(I)+C(J)
152   CONTINUE
      S1=S
      S=0.
      DO 155 I=1,N
      V=-R(I)/Q
      R(I)=V/W(I,1)
      S=S+V*R(I)
155   CONTINUE
      E1=E
      E=Q*S/S1
      Q1=Q
      Q=1.-E
C     SPECIAL FIXUP FOR LAST ITERATION.
      IF(S.LE.SM)Q=1.
C     UPDATE COL. SCALING POWERS
      QM=Q*Q1
      DO 160 I=1,N
      W(I,4)=(EM*W(I,4)+C(I))/QM
      W(I,3)=W(I,3)+W(I,4)
160   CONTINUE
      IF(S.LE.SM)GO TO 186
C     UPDATE RESIDUAL.
      DO 180 I=1,N
      C(I)=C(I)*E*W(I,2)
180   CONTINUE
185   CONTINUE
186   DO 188 I=1,N
      R(I)=R(I)*W(I,1)
188   CONTINUE
C
C      SWEEP THROUGH MATRIX TO PREPARE TO GET ROW SCALING POWERS
190   DO 200 K=1,NA
      IF(A(K).EQ.0.0 )GO TO 200
      I=IRN(K)
      J=ICN(K)
      R(I)=R(I)+W(J,3)
  200 CONTINUE
C
C      FINAL CONVERSION TO OUTPUT VALUES.
      DO 220 I=1,N
      R(I)=R(I)/W(I,1)-W(I,5)
      C(I)=-W(I,3)
220   CONTINUE
      GO TO 250
230   IF(LP.GT.0)WRITE(LP,240)IFAIL
240   FORMAT(//13H ERROR RETURN,I2,10H FROM MC19)
250   RETURN
      END
      BLOCK DATA MC19CD
      INTEGER LP,IFAIL
      COMMON/MC19BD/LP,IFAIL
      DATA LP/6/
      END
