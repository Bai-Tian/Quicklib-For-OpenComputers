# Quicklib-For-OpenComputers
简介：这是一个能帮助你开发oc程序的非常轻量的库。你可以非常简单的进行创建控件、绑定事件等操作。

# APIs
## box控件
qk_box(:table)  
新建一个box控件，返回一个控件id值，当你对控件进行编辑或者删除操作时会用到这个id。  
输入的table格式如下，“x=1”说明如果不给x赋值则默认x为1。  
变量 描述  
x=1 控件的x坐标  
y=1 控件的y坐标  
dx=5 控件的x方向长度  
dy=1 控件的y方向长度  
rf=1 刷新间隔时间  
func={} 各种函数  
func.touch() 点击事件激活的函数  
func.draw() 自定义绘制函数。如果此函数存在，自带的绘制函数不会启用  

自带的绘制函数：  
fc=0X000000 前景色  
bc=0XFFFFFF 背景色  
char=" " fill时的字符  
text 显示的文本  

qk_del(控件的id:number)  
删除此id的控件  
