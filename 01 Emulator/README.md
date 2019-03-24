# 操作环境
基本的流程是你在已有的操作系统上写东西，写完转换成相应格式，然后用Emulator跑起来看效果，[Emulator相当于一台裸机](https://stackoverflow.com/questions/1584617/simulator-or-emulator-what-is-the-difference)。
所以直接装一个发行版linux，在里面直接跑Bochs。
>你的linux -> Bochs -> 正在实现的os

书上的做法是在你的Windows/Linux/MacOS里跑一个虚拟机，虚拟机跑的是centos6的，接着在centos里跑Emulator,Emulator是Bochs2.6.2。
>Windows/Linux/MacOS -> 虚拟机(centos6) -> bochs2.6.2 -> 正在实现的os

但是虚拟机又带来一层复杂性，网络相关的配置比较头痛，导致不能上网不能互传文件很麻烦。虽然原则上不一定是linux，但是要做不少编译，我觉得没必要改个系统重新折腾。

# 解说
是书中第1章的内容，主要就是搭起环境，让bochs跑起来。因为是bochs相关的，和主题操作系统关系不大，所以基本都是照着来，没什么需要花心思想的。
bochs配置稍微可以说说，这个配置相当于指定了机器的规格。
几个选项的说明

* megs 内存
* romimage ROM
* vgaimage 显存ROM
* boot 启动方式，这里用了硬盘
* log 日志输出文件
* mouse 鼠标
* keyboard-mappinig 键盘映射
* ata0 硬盘设置

# 原料
书上用的2.6.2，能下到就不折腾用新版本了。
[下bochs-2.6.2.tar.gz](https://sourceforge.net/projects/bochs/files/bochs/2.6.2/)


# 操作
一通操作我全在本地的仓库目录/bin下进行的，所以安装在仓库/bin/bochs里
## 解压
	tar zxvf bochs-2.6.2.tar.gz
	
## 编译
自己编译也是书上的做法，可以enable不同选项弄着玩。**建议先用自带的包管理装一遍bochs解决编译的依赖问题，再自己编译，血的教训。**

cd到解压好bochs源码的目录，configure生成Makefile，此处**/your_path/bochs** 替换成bochs要安装的路径。

	./configure \
	--prefix=/your_path/bochs \
	--enable-debugger \
	--enable-disasm \
	--enable-iodebug \
	--enable-x86-debugger \
	--with-x \
	--with-x11
	
然后编译

	make
	
如果有pthread相关的错误，在Makefiled的92行加以个 -lpthread，像这样

	LIBS =  -lm -lgtk-x11-2.0 -lgdk-x11-2.0 -latk-1.0 -lgio-2.0 -lpangoft2-1.0 -lpangocairo-1.0 -lgdk_pixbuf-2.0 -lcairo -lpango-1.0 -lfontconfig -lgobject-2.0 -lglib-2.0 -lpthread -lfreetype
	
	
	
最后安装

	make install
	
## 创建硬盘
**/your_path/bochs** 下有个bin/bximage，可以生成一个bochs用的硬盘文件，生成的文件叫**hd60M.img**

	./bin/bximage -hd -mode="flat" -size=60 -q hd60M.img

复制下生成时候的一句话，下面要用

	ata0-master: type=disk, path="hd60M.img", mode=flat, cylinders=121, heads=16, spt=63
	
	

## 创建bochs配置
基本配置，要更改**/your_path/bochs**为bochs的安装目录。最后一行就是刚刚生成硬盘复制来的。保存为**bochsrc.disk**

	megs: 32
	romimage: file=/your_path/bochs/share/bochs/BIOS-bochs-latest
	vgaromimage: file=/your_path/bochs/share/bochs/VGABIOS-lgpl-latest
	boot: disk
	log: bochs.out
	mouse: enabled=0
	keyboard_mapping: enabled=1, map=/your_path/bochs/keymaps/x11-pc-us.map
	ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14
	ata0-master: type=disk, path="hd60M.img", mode=flat, cylinders=121, heads=16, spt=63
	
	
## 启动bochs
刚刚生成的**hd60M.img** **bochsrc.disk**放在一起，再用bochs启动

	bin/bochs -f bochsrc.disk
	
按6，新开了一个黑框就完成了
