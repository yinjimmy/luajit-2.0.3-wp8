luajit for wp8

x86的编译方法：
进入Visual Studio x86 Phone Tools Command Prompt，执行wp8build_x86.bat

arm的编译方法：
进入Visual Studio ARM Phone Tools Command Prompt，执行wp8build_arm.bat


和原来版本的修改，增加了WP8宏,修改了以下文件
1）src/lib_io.c
2）src/lib_jit.c
3）src/lib_os.c
4）src/lib_package.c
5）src/lj_arch.h


已知问题：
1 arm可以编译，但是无法执行，问题在于
1）wp8仅仅支持thumb2指令，不支持arm指令，因此需要使用thumb2指令重写
2）除了asm文件还有lj_bcdef.h需要按照thumb指令进行变化，除非修改lj_bcdef.h的结构
	lj_bc_ofs其实是每个函数的偏移量,可以使用dumpbin获取对应函数偏移量的地址

2 不支持FFI和JIT
  JIT是一定不支持的
