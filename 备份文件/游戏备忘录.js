1.战斗文件是：工程下的comLogic 和 config 两个目录下的内容，同步即为将这两个目录的代码打包发给服务器端进行同步

2.改变游戏速度：node:getScheudler():setTimeScale(2)  --设置为正常的2倍  cc.Director:getInstance():getScheduler()

3.禁止自动锁屏：-- [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

4.cocos2dx下，关于平台的判断：CC_TARGET_PLATFORM 这个宏可以判断
比如要判断是否是IOS平台：
if (CC_TAGET_PLATFORM == CC_PLATFORM_IOS)
{
	//是ios平台
}
elseif (CC_TAGET_PLATFORM == CC_PLATFORM_ADNROID)
{
	//是安卓平台	
}

5.globalZOrder 是用于 渲染器 中用来给“绘制命令”排序的
  localZOrder 是用于父节点的子节点数组中给 节点 对象排序的

6.节点如果设为不可见(this._visible = false;)那么该节点不会被渲染(即不会表现出来)

7.Scene::render(...)的逻辑是先用自定义相机去渲染相应节点， 最后再使用default相机渲染相应节点。


8.坐标转换:
convertToWorldSpace：把基于当前节点的本地坐标系下的坐标转换到世界坐标系中。 
convertToNodeSpace：把世界坐标转换到当前节点的本地坐标系中。 
这两种转换都是不考虑锚点的，都以当前节点父类的左下角的坐标为标准(原点)。
另外，CCNode还提供了convertToWorldSpaceAR和convertToNodeSpaceAR。
这两个方法完成同样的功能，但是它们的基准坐标是基于坐标锚点的:即锚点所在点即是原点。

9.javascript中：对数组排序 => array.sort(func || null)
如果调用该方法时没有使用参数，将按字母顺序对数组中的元素进行排序，说得更精确点，是按照字符编码的顺序进行排序。要实现这一点，首先应把数组的元素都转换成字符串（如有必要），以便进行比较。
如果想按照其他标准进行排序，就需要提供比较函数，该函数要比较两个值，然后返回一个用于说明这两个值的相对顺序的数字。比较函数应该具有两个参数 a 和 b，其返回值如下：
若 a 小于 b，在排序后的数组中 a 应该出现在 b 之前，则返回一个小于 0 的值。
若 a 等于 b，则返回 0。
若 a 大于 b，则返回一个大于 0 的值。

PS:如果a需要交换到b后面 则返回一个大于 0 的值，否则返回一个小于或等于 0 的值。

<script type="text/javascript">

function sortNumber(a,b)//从小到大排序
{
    return a - b; //return a > b;
}

var arr = new Array(6)
arr[0] = "10";
arr[1] = "5";
arr[2] = "40";
arr[3] = "25";
arr[4] = "1000";
arr[5] = "1";

document.write(arr + "<br />")
document.write(arr.sort(sortNumber))

</script>

10.coocs2d_lua中的定时器：
1.self:scheduleUpdateWithPriorityLua(updateFunc, priority)
>参数一：刷新函数
>参数二：刷新优先级
其中self为Node类的子类，该方法默认每帧都刷新一次，无法自定义刷新时间间隔
2.scheduler:scheduleScriptFunc(updateFunc, interval, pause) --常用
>参数一：刷新函数
>参数二：每次刷新的事件间隔
>参数三：是否只执行一次: false 表示 无限次
其中scheduler为定时器管理：cc.Director:getInstance():getScheduler()
PS:scheduler:unscheduleScriptEntry(callbackEntry)用于删除该定时器
3.使用Action来实现的 循环定时器 和 一次回调定时器
这两种是和Node相关的，因此当Node被移除出场景或者其他情况下，这类回调定时器将会被取消
function schedule(node, callback, delay)
    local delayAc = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(cc.CallFunc:create(callback), delayAc)
    local action = cc.RepeatForever:create(sequence)
    node:runAction(action)
    return action
end

function performWithDelay(node, callback, delay)
    local delayAc = cc.DelayTime:create(delay)
    local action = cc.Sequence:create(delayAc, cc.CallFunc:create(callback))
    node:runAction(action)
    return action
end

11.使用git add添加要提交的文件的时候，如果文件名是中文，会显示形如 274\232\350\256\256\346\200\273\347\273\223.png 的乱码。 
    解决方案：在bash提示符下输入：==> git config --global core.quotepath false
                                core.quotepath设为false的话，就不会对0x80以上的字符进行quote。中文显示正常。 

12.在cocosCreator中创建脚本的时候:会生成一个onLoad方法(use this for initialization)
onLoad方法会在场景加载后立刻执行，所以在其他代码中调用时，可以先为其设置参数，
待场景加载时，脚本会直接使用传入的参数。

13.ASCII UTF-8 Unicode  三者都是编码。
现在计算机系统通用的字符编码工作方式是：
    在计算机内存中，统一使用Unicode编码，当需要保存到硬盘或者需要传输的时候，就转换为UTF-8编码。
    Unicode 和 UTF-8 都能保证不会再出现乱码问题，但是某些情况下，前者会比后者占用更多空间。

14.在操作字符串时，会经常遇到str和bytes的互相转换，为了避免乱码问题，应当始终坚持使用utf-8编码对str和bytes进行转换。

15.一个字符对应若干个字节。如果需要在网络上传输，或者需要保存到磁盘上，就需要把str变为以字节为单位的bytes（建议使用UTF-8编码）

16.Python 对bytes类型的数据用带b前缀的单引号或双引号表示

17.encode  将str编码为bytes；decode  将bytes解码为str

18.在cocosCreator中：通过node.destroy()函数，可以销毁节点。
销毁节点并不会立刻被移除，而是在当前帧逻辑更新结束以后，统一执行。
当一个节点销毁后，该节点就处于无效状态，可以通过 cc.isValid 判断当前节点是否已经销毁。

19.destroy和removeFromParent()的区别：
调用一个节点的removeFromParent后，它不一定就能完全从内存中释放，
因为有可能由于一些逻辑上的问题，导致程序中仍然引用到了这个对象。
==> 因此如果一个节点不再使用了，请直接调用它的 destroy 而不是removeFromParent。
destroy不但会激活组件上的onDestroy，还会降低内存泄漏的几率，同时减轻内存泄漏时的后果。

20.onEnter和onExit在lua中不会因节点被add和remove而直接被调用，
当子节点被父节点add和remove时，会发送enter和exit的消息，所以需要在初始化节点的时候，
监听消息，并在收到消息后调用onEnter或者onExit函数。

onEnter是进入场景的一瞬间执行的，onEnterTransitionDidFinish是在完全进入场景后开始执行的（过渡动画结束，如果有的话）

21.project.manifest 是什么文件？

project.manifest ==> 打开后，内容如下
{ 
    "packageUrl" : "http://192.168.1.11:8000/res", 
    "remoteManifestUrl" : "http://192.168.1.11:8000/res/project.manifest", 
    "remoteVersionUrl" : "http://192.168.1.11:8000/res/version.manifest", 
    "version" : "1.0.1", 
    "engineVersion" : "3.0 rc0", 
    "assets" : { 
        "src/app.zip" : { 
            "md5" : "D07D260D8072F786A586A6A430D0E98B", 
            "compressed" : true 
        } 
    },

    "searchPaths" : [ 
    ] 
}

cocos2d程序安装后，以Android为例，程序会存在于2个地方：apk安装目录 和 apk数据目录

这个文件是使用脚本打完更新包后其中的文件，cocos2d提供的AssetsManager类会根据project.manifest 文件的配置，
把新文件下载到apk数据目录，并默认把这个下载目录设置为最优先搜索的地方。

version：用于版本比较
md5：当在下次更新时用来比較这次与上次下载下来的manifest文件里相应的包的md5 码是否同样，不同的话须要做些处理（更新。删除操作）。

22.搜索:[ cocos  AssetsManager动态更新配置文件详解 ]

23.热更新的思路：
玩家一启动游戏时，将客户端资源的版本与服务器上的进行比对，
如果客户端版本抵御服务端版本，则下载最新的资源，并将客户端的资源版本更新至服务端的版本。
由于我们没有对打包出来的APK中的资源有写的权限，所以我们需要将下载下来的资源放在一个可以读写的路径中，
并添加这个路径至搜索路径，且优先级要高于默认的搜索路径。

23.热更新计算差异文件总量:
unsigned long AssetsManagerEx::getDownloadSize()
{
    // 获取差异文件
    std::unordered_map<std::string, Manifest::AssetDiff> diff_map = _localManifest->genDiff(_remoteManifest);
    
    if (diff_map.size() == 0) {
        return 0;
    } else {
        unsigned long bytes = 0;
        auto assets = _tempManifest->getAssets();
        
        for (auto it = diff_map.begin(); it != diff_map.end(); ++it)
        {
            Manifest::AssetDiff diff = it->second;
            
            auto tempIt = assets.find(it->first);
            if (tempIt != assets.end() && tempIt->second.downloadState == Manifest::DownloadState::SUCCESSED)
            {   // 已完成的不记入大小
                continue;
            }
            
            bytes += diff.asset.size;
            
        }
        return bytes;
    }
}
相关变量类型查看源码能知道。
AssetDiff结构体包含了Asset结构体和一个DiffType枚举
Asset结构体包含了一系列变量，比如 size， md5， downloadState， version等
DiffType枚举包含了三个值： ADDED,DELETED,MODIFIED

24.XCode:undefined symbols for architecture x86_64错误解决方案
1.如果报错问题来源是出自于第三方库：
    那么在 TRARGET(项目) 旁边的 build Phases 栏的Link Binary With Libraries中 添加框架或者静态库
2.如果不是，比如是自己写的类：
    那么需要在 TRARGET(项目) 旁边的 build Phases Compile Sources 加入 .m class 或者 .cpp class 然后 build_and_run

25.git merge 命令是用于从指定的commit合并到当前分支的操作
git merge 命令有以下两种用途：
1 用于git pull：来整合另一代码仓库中的变化（即：git pull = git fetch + git merge)
2 用于从一个分支到另一个分支的合并

假设下面的历史节点存在，并且当前所在的分支为“master”:
         A---B---C topic
        /
---D---E---F---G master

那么git merge topic命令将会把在master分支上二者共同的节点（E节点）之后分离的节点（即topic分支的A B C节点）
重现在master分支上，直到topic分支当前的commit节点（C节点），并位于master分支的顶部。
并且沿着master分支和topic分支创建一个记录合并结果的新节点，该节点带有用户描述合并变化的信息。

即下图中的H节点，C节点和G节点都是H节点的父节点。

         A---B---C topic
        /         \
---D---E---F---G---H master

3 git merge --abort 命令仅仅在合并后导致冲突时才使用。
git merge --abort 将会抛弃合并过程并且尝试重建合并前的状态。但是当合并开始时如果存在未commit的文件，
git merge --abort 在某些情况下将无法重现合并前的状态。（特别是这些未commit的文件在合并过程中将会被修改时）

警告：运行git merge时含有大量的未commit文件很容易让你陷入困境，这将使你在冲突中难以回退。
因此非常不鼓励在使用git merge时存在未commit的文件，建议使用git stash命令将这些未commit文件暂存起来，
并在解决冲突以后使用git stash pop把这些未commit文件还原出来。

26.游戏中多国语言的处理(切换):
所有的文字字段的翻译通过一份plist文件存储，形成一张二维表(这是关键)。
当需要切换语言时，只需要改变某个key相对的value就可以了，逻辑层不需要做改变。

27.MVC即Model View Controller，是模型(model)－视图(view)－控制器(controller)的缩写。
MVC是一种“前端”的设计模式。
使用MVC的目的是：希望View和Model分离，当某一方改变时，而另一方不必随之改变的。

28.touch position 是屏幕坐标系(原点在左上角)中的点坐标，
  opengl position 是cocos2d用到的opengl坐标系上的点坐标，


  手机屏幕触摸事件Touch传入的位置信息使用的是屏幕坐标系，
  因此在Cocos2D-x中对触摸事件做出响应前，
  需要先把触摸点转化到OpenGL坐标系(
    所以需要将touch position 转换为 opengl position
  )

   // returns the current touch location in screen coordinates
   Vec2 Touch:: getLocationInView() const
   {
        return _point; 
   }

    // returns the current touch location in OpenGL coordinates
    Vec2 Touch::getLocation() const
    { 
        return Director::getInstance()->convertToGL(_point); 
    }

29.js的sort()方法用于对数组的元素进行排序并返回数组，默认排序顺序是按照字符编码的顺序进行的。
            可以接受一个比较函数:function(a, b){ ... }
            如果想在排序后的数组中:a 出现 在 b 的左侧，则返回一个小于0的值，（-1）
                                :a 和 b 权重相同，则返回0，
                                :a 出现 在 b 的右侧，则返回一个大于0的值。（1）
            位置(从左到右):    -1     0     1

30.js的箭头函数(=>) 和 匿名函数有一个明显的区别:
            箭头函数内部的this是词法作用域，由上下文确定。
            匿名函数默认指向window或者为undefined(可以通过 var that = this 来处理)

31.Node.js模块里，exports与module.exports的区别？
            在模块文件（***.js)创建后exports 和 module.exports都会被初始化为空对象{}： exports = module.exports = {};
            exports是module.exports的一个"引用"
            require模块时，引入的是module.exports这个对象，而不是exports这个对象。
            在写模块文件时，结尾常是：module.exports = ***;

32.cocos2d_lua 贝塞尔曲线配置：
        --贝塞尔曲线运动
        local bezierConfig = {
            cc.p(64, 10),--controlPoint_1
            cc.p(130, 30),--controlPoint_2
            cc.p(147.5, 94),--endPosition
        }
        node:runAction(cc.[BezierBy|BezierTo]:create(time, bezierConfig)) --时间，配置

33.cocos2d_lua:lua下建议不要使用node:registerScriptHandler注册事件，而是使用node:onNodeEvent
    同一个node在多个地方调用registerScriptHandler方法注册不同的事件，会导致仅一个有效

33.ORM：object relational mapping =>对象关系映射(把关系数据库的表结构映射到对象上)
    数据库表是一个二维表，包含多行多列。把一个表的内容用Python的数据结构表示出来的话，
    可以用一个list表示多行，list的每一个元素是tuple，表示一行记录，比如 包含id和name的user表：
    [
        ('1', 'Michael'),
        ('2', 'Bob'),
        ('3', 'Adam')
    ]
    Python的DB - API返回的数据结构就是像上面这样表示的。
    但是用tuple表示一行很难看出表的结构。如果把一个tuple用class实例来表示，就可以更容易看出表结构
    class User(object):
        def __init__(self, id, name):
            self.__id = id
            self.__name = name
    ------------------------------
    [
        User('1', 'Michael'),
        User('2', 'Bob'),
        User('3', 'Adam')
    ]
    ------------------------------
    ORM框架的作用就是把数据库表的一行记录与一个对象互相做自动转换。

34.在web开放中，“route”是指根据url分配到(跳转执行)对应的处理程序

35.MAC地址(Media Access Control) 译为媒体访问控制，或者称之为物理地址，硬件地址。
用来定义网络设备的位置，MAC地址是网卡决定的，是固定的。

36.requirements.txt 是一个文本文件，它被许多Flask应用程序用来列出运行应用
所有需要的包：
    pip freeze > requirements.txt

    pip install -r requments.txt





























