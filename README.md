# Quicklib-For-OpenComputers
这是一个能帮助你开发oc程序的非常轻量的库。你可以非常简单的进行创建控件、绑定事件等操作。

# APIs
创建控件：  
`qk_new(包含初始化数据的表:table,控件元表:table)`  
新建一个控件，返回一个控件id值，当你对控件进行编辑或者删除操作时会用到这个id。  
当第二个参数`控件元表`不存在时此函数默认新建一个box控件。  

删除控件：  
`qk_del(控件的id:number)`  
删除此id的控件。  

编辑控件：  
`qk_edit(控件的id:number,要编辑的内容组成的表:table)`
只会改变x,y,dx,dy,fc,bc,char,rf,text这几种属性  
如果想改变其他的属性请看下文`关于qk_data表`

## box控件
`qk_new(包含初始化数据的表:table)`  
在屏幕上显示一个长方形，返回一个控件id值，当你对控件进行编辑或者删除操作时会用到这个id。  
包含初始化数据的表的格式如下
| 变量 | 描述 |  
|----|----|  
`x=1`代表x的默认参数为1|-  
`:draw()`代表此函数使用`self`|-
x=1|控件的x坐标  
y=1|控件的y坐标  
dx=5|控件的x方向长度  
dy=1|控件的y方向长度  
rf=1（0.1的倍数）|刷新间隔时间。重要：当rf=0时，不会执行绘制函数，相当于隐藏效果   
:dest()|析构函数。当执行`qk_del()`时执行，不定义此函数则会使用默认析构函数  
:draw()|绘制函数。每隔`rf`段时间执行一次，不定义此函数则会使用默认绘制函数  
以下属性影响默认的绘制函数`draw()`|-  
text|显示的文本  
fc=0X000000|前景色  
bc=0XFFFFFF|背景色  
char=" "|fill时的字符  
以下为各种事件函数，不定义则无事发生|-  
:touch()|点击事件激活的函数  
:drag()|拖拽事件激活的函数
:drop()|释放鼠标激活的函数
:scroll()|滚动事件激活的函数
:walk()|行走事件激活的函数  
关于网卡事件的函数和属性|-
modem_sender|判断收到的消息是否来自此地址，缺省则不判断
modem_port|判断收到的消息是否来自此端口，缺省则不判断
modem_distance|判断收到的消息的距离（有线网卡为0），缺省则不判断
modem_msg|判断收到消息的第一个参数是否与此变量相同，缺省则不判断
:modem(...)|以上条件全部满足后执行此函数。传入的不定参数`...`为接收到的从第二个参数开始到最后的消息  

注意：此网卡事件只能做到简单的判断，复杂需求请自行实现。如果接收到的消息是多个参数，modem_msg只能判断接收到的消息的第一个参数。
### 关于qk_data表：
此表记录着所有创建过的控件，控件的id值即为控件在此表的索引。  
通过此表可以直接访问或修改控件的属性，例：`qk_data[控件的id][属性名称]`
在使用析构函数删除控件时只会把控件的type类型改为"n"，不可直接赋值nil。  

### 关于几个默认的函数的详细内容：  
默认的析构函数：（把type类型改成"n"代表已被删除的控件，不可直接赋值nil）
```
function mt_box:dest()  
    self = {type = "n"}
end
```
默认的绘制函数：
 ```
 function mt_box:draw() 
    local t=self
    local bk = gpu.getBackground()
    local fk = gpu.getForeground()
    gpu.setBackground(t.bc)
    gpu.setForeground(t.fc)
    gpu.fill(t.x, t.y, t.dx, t.dy, t.char)
    gpu.set(t.x, t.y, t.text)
    gpu.setBackground(bk)
    gpu.setForeground(fk)
end
```

