.class public GameOfLife
.super java/lang/Object

.field private static width I
.field private static height I
.field private static steps I
.field private static grid [[Z
.field private static next [[Z

.method public <init>()V
    .limit stack 1
    .limit locals 1
    aload_0
    invokespecial java/lang/Object/<init>()V
    return
.end method

.method private static countNeighbors([[ZII)I
    .limit stack 3
    .limit locals 8

    iconst_0
    istore_3

    iconst_m1
    istore 4

L_DY_LOOP:
    iload 4
    iconst_1
    if_icmpgt L_DY_END

    iconst_m1
    istore 5

L_DX_LOOP:
    iload 5
    iconst_1
    if_icmpgt L_NEXT_DY

    iload 4
    ifne L_CHECK_CELL
    iload 5
    ifne L_CHECK_CELL
    goto L_INC_DX

L_CHECK_CELL:
    iload_1
    iload 5
    iadd
    istore 6

    iload_2
    iload 4
    iadd
    istore 7

    iload 6
    iflt L_INC_DX
    iload 6
    getstatic GameOfLife/width I
    if_icmpge L_INC_DX

    iload 7
    iflt L_INC_DX
    iload 7
    getstatic GameOfLife/height I
    if_icmpge L_INC_DX

    aload_0
    iload 7
    aaload
    iload 6
    baload
    ifeq L_INC_DX

    iinc 3 1

L_INC_DX:
    iinc 5 1
    goto L_DX_LOOP

L_NEXT_DY:
    iinc 4 1
    goto L_DY_LOOP

L_DY_END:
    iload_3
    ireturn
.end method

.method private static step()V
    .limit stack 3
    .limit locals 7

    iconst_0
    istore_0

L_Y_LOOP:
    iload_0
    getstatic GameOfLife/height I
    if_icmpge L_SWAP

    getstatic GameOfLife/grid [[Z
    iload_0
    aaload
    astore 4

    getstatic GameOfLife/next [[Z
    iload_0
    aaload
    astore 5

    iconst_0
    istore_1

L_X_LOOP:
    iload_1
    getstatic GameOfLife/width I
    if_icmpge L_NEXT_Y

    aload 4
    iload_1
    baload
    istore_3

    getstatic GameOfLife/grid [[Z
    iload_1
    iload_0
    invokestatic GameOfLife/countNeighbors([[ZII)I
    istore_2

    iload_3
    ifeq L_DEAD_RULE

    iload_2
    iconst_2
    if_icmpeq L_ALIVE
    iload_2
    iconst_3
    if_icmpeq L_ALIVE

    aload 5
    iload_1
    iconst_0
    bastore
    goto L_NEXT_X

L_ALIVE:
    aload 5
    iload_1
    iconst_1
    bastore
    goto L_NEXT_X

L_DEAD_RULE:
    iload_2
    iconst_3
    if_icmpne L_STAY_DEAD

    aload 5
    iload_1
    iconst_1
    bastore
    goto L_NEXT_X

L_STAY_DEAD:
    aload 5
    iload_1
    iconst_0
    bastore

L_NEXT_X:
    iinc 1 1
    goto L_X_LOOP

L_NEXT_Y:
    iinc 0 1
    goto L_Y_LOOP

L_SWAP:
    getstatic GameOfLife/grid [[Z
    astore 6

    getstatic GameOfLife/next [[Z
    putstatic GameOfLife/grid [[Z

    aload 6
    putstatic GameOfLife/next [[Z

    return
.end method

.method private static printGrid(I)V
    .limit stack 4
    .limit locals 4

    getstatic java/lang/System/out Ljava/io/PrintStream;
    new java/lang/StringBuilder
    dup
    invokespecial java/lang/StringBuilder/<init>()V
    ldc "Generation "
    invokevirtual java/lang/StringBuilder/append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iload_0
    invokevirtual java/lang/StringBuilder/append(I)Ljava/lang/StringBuilder;
    invokevirtual java/lang/StringBuilder/toString()Ljava/lang/String;
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    iconst_0
    istore_1

L_PRINT_Y:
    iload_1
    getstatic GameOfLife/height I
    if_icmpge L_PRINT_DONE

    new java/lang/StringBuilder
    dup
    invokespecial java/lang/StringBuilder/<init>()V
    astore_3

    iconst_0
    istore_2

L_PRINT_X:
    iload_2
    getstatic GameOfLife/width I
    if_icmpge L_ROW_OUT

    getstatic GameOfLife/grid [[Z
    iload_1
    aaload
    iload_2
    baload
    ifeq L_DEAD_CHAR

    aload_3
    ldc "O"
    invokevirtual java/lang/StringBuilder/append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    pop
    goto L_NEXT_PRINT_X

L_DEAD_CHAR:
    aload_3
    ldc "."
    invokevirtual java/lang/StringBuilder/append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    pop

L_NEXT_PRINT_X:
    iinc 2 1
    goto L_PRINT_X

L_ROW_OUT:
    getstatic java/lang/System/out Ljava/io/PrintStream;
    aload_3
    invokevirtual java/lang/StringBuilder/toString()Ljava/lang/String;
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    iinc 1 1
    goto L_PRINT_Y

L_PRINT_DONE:
    getstatic java/lang/System/out Ljava/io/PrintStream;
    ldc ""
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
    return
.end method

.method private static seedPattern()V
    .limit stack 4
    .limit locals 0

    ; Glider 1
    getstatic GameOfLife/grid [[Z
    iconst_1
    aaload
    iconst_2
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    iconst_2
    aaload
    iconst_3
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    iconst_3
    aaload
    iconst_1
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    iconst_3
    aaload
    iconst_2
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    iconst_3
    aaload
    iconst_3
    iconst_1
    bastore

    ; Blinker
    getstatic GameOfLife/grid [[Z
    bipush 10
    aaload
    bipush 10
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 10
    aaload
    bipush 11
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 10
    aaload
    bipush 12
    iconst_1
    bastore

    ; Glider 2
    getstatic GameOfLife/grid [[Z
    bipush 15
    aaload
    bipush 16
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 16
    aaload
    bipush 17
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 17
    aaload
    bipush 15
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 17
    aaload
    bipush 16
    iconst_1
    bastore

    getstatic GameOfLife/grid [[Z
    bipush 17
    aaload
    bipush 17
    iconst_1
    bastore

    return
.end method

.method public static main([Ljava/lang/String;)V
    .limit stack 4
    .limit locals 2

    bipush 20
    putstatic GameOfLife/width I

    bipush 20
    putstatic GameOfLife/height I

    bipush 40
    putstatic GameOfLife/steps I

    getstatic GameOfLife/height I
    getstatic GameOfLife/width I
    multianewarray [[Z 2
    putstatic GameOfLife/grid [[Z

    getstatic GameOfLife/height I
    getstatic GameOfLife/width I
    multianewarray [[Z 2
    putstatic GameOfLife/next [[Z

    invokestatic GameOfLife/seedPattern()V

    iconst_0
    istore_1

L_MAIN_LOOP:
    iload_1
    getstatic GameOfLife/steps I
    if_icmpge L_END

    iload_1
    invokestatic GameOfLife/printGrid(I)V

    invokestatic GameOfLife/step()V

    iinc 1 1
    goto L_MAIN_LOOP

L_END:
    getstatic java/lang/System/out Ljava/io/PrintStream;
    ldc "Simulation complete."
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    return
.end method
