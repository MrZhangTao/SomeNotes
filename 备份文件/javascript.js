void Subject::removeObserver(Observer *observer)
{
	if (head_ == observer)
	{
		head_ = head_->next_;
		observer_->next = nullptr;
		return;
	}
	Observer *current = head_;
	while(current != nullptr)
	{
		if (current->next_ == observer)
		{
			current->next_ = observer->next_;
			observer->next_ = nullptr;
			return;
		}
		current = current->next_;
	}
}

void Subject::addObserver(Observer *observer)
{
	//添加在头部 省去链表查找减少复杂度
	observer->next_ = head_;
	head_ = observer;
	return;
}

JavaScript 支持不同类型的循环：
for - 循环代码块一定的次数
for/in - 循环遍历对象的属性
while - 当指定的条件为 true 时循环指定的代码块
do/while - 同样当指定的条件为 true 时循环指定的代码块

var list = document.getElementById("test-list");
Array.from(list.children).sort(function(next, pre){
 
 if (next.innerText > pre.innerText){
    alert("pre.innerText < next.innerText: " + pre.innerText + "  " + next.innerText);
    return 1;
 }
 if (next.innerText < pre.innerText){
    alert("pre.innerText > next.innerText: " + pre.innerText + "  " + next.innerText);
    list.insertBefore(next, pre);
    return -1;
 }
 return 0;
})
//Scheme JavaScript Python Ruby Haskell

ajax全称为：asynchronous javascript and xml 意思是使用javascript执行异步网络请求
在现代浏览器上写ajax主要依靠XMLHttpRequest对象：
function success(text){}//响应函数1
function fail(code){}//响应函数2
var request = new XMLHttpRequest();
request.onreadystatechange = function(){//状态发生改变时 该函数被回调
	//判断相应结果 然后执行相应的响应函数
}
request.open("GET", "/api/categories");//默认情况下javascript在发送ajax请求时 url的域名必须和当前页面完全一致
request.send();//发送请求
alert("请求已发送，请等待相应...");

在javascript中，所有的代码都是单线程执行的。
因此javascript所有的网络操作 浏览器事件 都必须是异步执行 异步执行可以用回调函数实现。

jQuery在全局对象$上绑定了ajax()函数  可以处理ajax请求。
ajax(url, settings)函数需要接收一个url和一个可选的settings对象

处理返回的数据和出错时的响应:
	"use strict";
	function ajaxLog(s){
		var txt = $("#test-response-text");
		txt.val(txt.val() + "\n" + s);
	}
	$("#test-response-text").val("");
	var jqxhr = $.ajax("/api/categories", {
		dataType: "json"
	}).done(function(data){
		ajaxLog("成功，收到的数据: " + JSON.stringify(data));
	}).fail(function(xhr, status){
		ajaxLog("失败: " + xhr.status + ", 原因: " + status);
	}).always(function(){
		ajaxLog("请求完成: 无论成功或者失败都会调用！");
	});

对于常用的ajax操作 jQuery还提供了get post getJSON方法。

jQuery对象可以操作一组DOM 还支持链式操作，用起来很方便。
可以扩展jQuery来实现自定义方法：这种方式也称为jQuery插件。
给jQuery对象绑定一个新方法是通过扩展$.fn对象实现的
eg:
	$.fn.highlight = function(){
		//this已经绑定为当前的jQuery对象 所以函数内部代码可以正常调用所有jQuery对象的方法
		this.css("backgroundColor", "#fffceb").css("color", "#d85033");
		return this;
	}

编写一个jQuery插件的原则：

给$.fn绑定函数，实现插件的代码逻辑；
插件函数最后要return this;以支持链式调用；
插件函数要有默认值，绑定在$.fn.<pluginName>.defaults上；
用户在调用时可传入设定值以便覆盖默认值。

使用try catch finally 处理错误（PS:catch 和 finally可选择出现）
var r1, r2, s;
try{
	r1 = s.length;//此处应产生错误
	r2 = 100; //该语句不会执行
}catch (e){
	alert("出错了：" + e);
}finally{ //该块一定会被执行。
	console.log("finally...");
}

错误类型：javascript有一个标准的  Error对象  表示错误 还有从Error派生的TypeError ReferenceError
等错误对象。我们再处理错误时 可以通过catch(e)捕获的 变量e 访问错误对象。

程序也可以主动抛出一个错误：让执行流程直接跳转到catch块 抛出错误使用throw语句。
var r, n, s;
try{
	s = prompt("请输入一个数字");
	n = parseInt(s);
	if (isNaN(n)){
		throw new Error("输入错误");
	}
	//计算平方
	r = n * n;
	alert(n + " * " + n + " = " + r);
}catch(e){
	alert("出错了：" + e);
}

如果在一个函数内部发生了错误 它自身没有捕获 错误就会被抛到外层调用函数 如果外层函数也没有捕获
该错误会一直沿着函数调用链向上抛出 直到被JavaScript引擎捕获 代码终止执行。

涉及到异步代码，无法再调用是捕获 原因就是在捕获的当时 回调函数并未执行
类似的 在处一个事件时，在绑定事件的代码处 无法捕获事件处理函数的错误

$btn.click(function(){
	try{
		var
			x = parseFloat($("#x").val()),
			y = parseFloat($("#y").val()),
			r;
		if (isNaN(x) || isNaN(y)){
			throw new Error("输入有误");
		}
		r = x + y;
		alert("计算结果：" + r);
	}catch(e){
		alert(e.message);
	}
});

<html>
<body>
<script type="text/javascript">//现代浏览器已经将javascript设为默认脚本语言了 所以可以不写type属性
var str="Visit Micro/soft!"
document.write(str.replace(/Micro\/soft/,"W3S'chool"))
document.write("<p>" + str.replace(/W3S'chool/, "Micro/soft") + "</p>");
</script>
</body>
</html>

定义RegExp RegExp对象用于存储检索模式
=> 可以向 RegExp 对象添加第二个参数，以设定检索。
=> 例如，如果需要找到所有某个字符的所有存在，则可以使用 "g" 参数 ("global")。
通过new关键词来定义RegExp对象 var pattr = new RegExp("\\w+");
RegExp对象有3个方法：
test()		检索字符串的指定值 返回值是true或false
			var pattr = new RegExp("\\w+");pattr.test("HelloWorld_")
exec()		检索字符串中的指定值。返回值是被找到的值 如果没有发现匹配则返回null
			var pattr = new RegExp("\\w+");pattr.exec("123w+_");
compile()	
