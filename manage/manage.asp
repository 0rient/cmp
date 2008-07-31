﻿<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
If Session(CookieName & "_flag")="" Then
	response.Redirect("login.asp")
end if
'//////////////////////////////
Select Case Request("action")
Case "manage"
	Call guide()
	Call manage()
	Call Footer()
Case "save_manage"
	Call guide()
	Call save_manage()	
	Call Footer()
Case "class_manage"
	Call guide()
	Call class_manage()
	Call Footer()
Case "save_class_manage"
	Call guide()
	Call save_class_manage()
	Call Footer()
Case "config"
	Call guide()
	Call config()
	Call Footer()
Case "save_config"
	Call guide()
	Call save_config()
	Call Footer()
Case "make_xml"
	Call guide()
	Call make_xml()
	Call Footer()
Case "show"
	Call guide()
	Call show()
	Call Footer()
Case "check_music_name"
	Call check_music_name()
Case "make_lrc"
	Call make_lrc()
	Call Footer()
Case Else
	Call guide()
	Call main()
	Call Footer()
End Select
If Errmsg<>"" Then cenfun_error()

sub guide()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th>CenFun Music Player 音乐管理中心</th>
  </tr>
  <tr>
    <td class="cmsRow"><a href="?">音乐列表</a> | <a href="?action=manage">添加音乐</a> | <a href="?action=class_manage">专辑管理</a> | <a href="?action=config">播放器配置</a> | <a href="?action=make_xml" title="所有的操作完成，最后请务必在这里生成xml文件方能更新信息！"><font color="#ff0000">生成XML文件</font></a> | <a href="?action=show">查看效果</a></td>
  </tr>
</table>
<br>
<%
end sub

sub main()
dim num
dim cfclass_list
	sql="select classid,classname from cfplay_class order by sn"
	set rs=conn.execute(sql)
		if rs.bof or rs.eof then
			Errmsg=Errmsg&"<li>至少需要一个专辑,请先<a href=""?action=class_manage""><strong>添加</strong></a>"
			cenfun_error()
			exit sub
		else
			cfclass_list=rs.GetRows()
		end if
	rs.close
	set rs=nothing
dim classid,classname
if request("classid")<>"" and IsNumeric(request("classid")) then
	classid=request("classid")
end if

dim selectm,selectkey,classsql
dim lrc_select,pic_select
selectm=trim(request("selectm"))
selectkey=trim(request(trim("selectkey")))
	if selectkey="" then
		selectm=""
	end if
lrc_select=request("lrc_select")
pic_select=request("pic_select")
%>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="1">
  <form name="form_search" method="post" action="?classid=<%=classid%>&page=<%=request("page")%>">
    <tr>
      <td align="center"><table border="0" align="center" cellpadding="2" cellspacing="0">
          <tr align="center">
            <td><select name='JumpClass' id="JumpClass" onChange="if(this.options[this.selectedIndex].value!='0'){location='?classId='+this.options[this.selectedIndex].value;}">
                <option value='' selected>所有专辑</option>
                <%
for num=0 to UBound(cfclass_list,2)
	response.write "<option value='"&cfclass_list(0,num)&"' "
	if trim(cfclass_list(0,num))=classid then
		response.write "selected"
	end if
	response.write ">"&cfclass_list(1,num)&"</option>"	
next
%>
              </select>
            </td>
            <td><strong>关键字</strong></td>
            <td><input name="selectkey" type="text" size="15" id="selectkey" onDblClick="this.value=''" value="<%=selectkey%>"></td>
            <td><select name="selectm" id="select">
                <option value="title">按名称</option>
                <option value="url" <%if selectm="url" then%>selected="selected"<%end if%>>按地址</option>
                <option value="content" <%if selectm="content" then%>selected="selected"<%end if%>>按内容</option>
              </select>
            </td>
            <td><select name="lrc_select">
                <option value="">歌词不限</option>
                <option value="0" <%if lrc_select="0" then%>selected="selected"<%end if%>>无歌词</option>
                <option value="1" <%if lrc_select="1" then%>selected="selected"<%end if%>>有歌词</option>
              </select>
            </td>
            <td><select name="pic_select">
                <option value="">图片不限</option>
                <option value="0" <%if pic_select="0" then%>selected="selected"<%end if%>>无图片</option>
                <option value="1" <%if pic_select="1" then%>selected="selected"<%end if%>>有图片</option>
              </select>
            </td>
            <td><input type="submit" name="Submit2" value="搜 索"></td>
          </tr>
        </table></td>
    </tr>
  </form>
</table>
<table border="0" cellspacing="1" cellpadding="2" align=center class="tableBorder">
  <form name="form_main" method="post" action="?classid=<%=classid%>&page=<%=request("page")%>">
    <tr>
      <th height="25" colspan="9" align="center"><strong>内容列表</strong></th>
    </tr>
    <tr align="center" class="cmsRow">
      <td nowrap><input name="chkAll" type="checkbox" id="chkAll" onClick="CheckAll(this.form)" value="checkbox" /></td>
      <td nowrap>序号</td>
      <td nowrap>名称</td>
      <td>专辑</td>
      <td nowrap>介绍</td>
      <td nowrap="nowrap">Url/Lrc/Pic</td>
      <td nowrap>更新时间</td>
    </tr>
    <%
'############################删除选项#######################################
dim selectid
selectid=request("selectid")  
if request("del")="删除所选" and selectid<>"" then
conn.execute("delete from cfplay_list where id in ("&selectid&")")
response.redirect Request.ServerVariables("HTTP_REFERER")
end if
'##############################专辑#########################################
  if classid<>"" and IsNumeric(classid) then
	 classsql="and classid="&classid
  end if
'#########################自动批量排序######################################
dim sum,autosn
sum=1
autosn=Replace(trim(Request("autosn")),"'","")
if autosn<>"" then
set rs=conn.execute("select id from cfplay_list order by "&autosn&" desc")
do while not rs.eof
conn.execute("update cfplay_list set sn="&sum&" where id="&rs("id"))
sum=sum+1
rs.movenext
loop
rs.close
set rs=nothing
end if
 
'############################排序选项#######################################
if request("sn")="排序所选" and selectid<>"" then
'response.Write ""
dim selectidlist
    selectidlist=split(selectid,", ")
'response.Write ""
 for i=0 to ubound(selectidlist)
if IsNumeric(request.form("sn"&selectidlist(i))) then 
conn.execute("update cfplay_list set sn="&request.form("sn"&selectidlist(i))&" where id="&int(selectidlist(i))&"")
end if
 next

'response.redirect Request.ServerVariables("HTTP_REFERER")
'response.Redirect "?classid="&request("classid")
end if

'#############################分页显示######################################
    dim CurrentPage,totalnumber,page_count,MaxPerPage,Pagenumber
    MaxPerPage=10 '每页显示数目
	CurrentPage=request("page")
	if CurrentPage="" or not IsNumeric(CurrentPage) then
		CurrentPage=1
	else
		CurrentPage=clng(CurrentPage)
		if err then
			CurrentPage=1
			err.clear
		end if
	end if

'##########  查询过滤  ############
dim sql1
	sql1=" order by sn,lasttime desc "
select case selectm
	case ""
        sql=" title like '%"&selectkey&"%' "&classsql&" "
	case "title"
        sql=" title like '%"&selectkey&"%' "&classsql&" "
	case "url"
        sql=" url like '%"&selectkey&"%' "&classsql&" "
	case "content"
        sql=" content like '%"&selectkey&"%' "&classsql&" "
	case else
        sql=" 1=1 "&classsql&" "
end select
if lrc_select="0" then
	sql=sql&" and lrc='' "
elseif lrc_select="1" then
	sql=sql&" and lrc<>'' "
end if
if pic_select="0" then
	sql=sql&" and pic='' "
elseif pic_select="1" then
	sql=sql&" and pic<>'' "
end if

Set Rs=conn.execute("Select count(id) From cfplay_list Where "&sql&" ")
totalnumber=Rs(0)
Rs.close:Set Rs=Nothing

set rs=conn.execute("select id,classid,title,url,lrc,content,pic,lasttime,sn from cfplay_list where "&sql&" "&sql1&" ")
'##########分页############		  
    if err.number<>0 or (rs.eof And rs.bof) then
		Response.Write "<tr><td colspan=8 align=center class=cmsRow><font color=#ff0000>没有找到相关信息!</font></td></tr>"
   	else
  	if totalnumber mod MaxPerPage=0 then
     		Pagenumber= totalnumber \ MaxPerPage
  	else
     		Pagenumber= totalnumber \ MaxPerPage+1
  	end if
	RS.MoveFirst
	if CurrentPage > Pagenumber then CurrentPage = Pagenumber
   	if CurrentPage<1 then CurrentPage=1
	RS.Move (CurrentPage-1) * MaxPerPage
	page_count=0	
    do while not rs.eof and page_count < Clng(MaxPerPage)
%>
    <tr class="cmsRow" onMouseOver="this.style.backgroundColor='#E4E4E4'" onMouseOut="this.style.backgroundColor=''">
      <td align="center"><input name="selectid" type="checkbox" id="selectid" value="<%=rs("id")%>"></td>
      <td align="center"><input type="text" name="sn<%=rs("id")%>" id="sn<%=rs("id")%>" size="3" maxlength="6" value="<%=rs("sn")%>"></td>
      <td nowrap="nowrap"><a href="?action=manage&manage=edit&classid=<%=classid%>&id=<%=rs("id")%>" title="点击修改"><%=rs("title")%></a></td>
      <td align="center" nowrap><%
classname="未知分类"
for num=0 to UBound(cfclass_list,2)
	if trim(cfclass_list(0,num))=trim(rs("classid")) then
		classname="<a href=?classid="&cfclass_list(0,num)&">"&cfclass_list(1,num)&"</a>"
	end if
next
response.write classname
%></td>
      <td><%=rs("content")%></td>
      <td align="center"><a href="<%=rs("url")%>" target="_blank" title="点击直接打开音乐地址"><img src="images/mp3.gif" width="16" height="16" border="0" /></a>
        <%if rs("lrc")<>"" then%>
        <img src="images/lrc.gif" width="16" height="16" border="0" />
        <%else response.write("<img src=""images/null.gif"" width=""16"" height=""16"" border=""0"" /> ") end if%>
        <%if rs("pic")<>"" then%>
        <img src="images/jpg.gif" width="16" height="16" border="0" />
        <%else response.write("<img src=""images/null.gif"" width=""16"" height=""16"" border=""0"" /> ") end if%></td>
      <td align="center" nowrap><%=FormatDateTime(rs("lasttime"),2)%></td>
    </tr>
    <%
		page_count=page_count+1
		rs.movenext
	loop
	end if
	rs.close
	set rs=nothing
'########################################end############################################
%>
    <tr>
      <td height="30" colspan="9" align="center" class="cmsRow"> 对选项进行操作:
        <input type="submit" name="sn" value="排序所选">
        <select name="autosn" id="select" onChange="{if(confirm('确定对以上所有内容重新排序吗?')){submit();}return false;}">
          <option value="">自动排序</option>
          <option value="addtime">按添加时间</option>
          <option value="lasttime">按更新时间</option>
          <option value="id">按数据ID</option>
          <option value="title">按名称</option>
        </select>
        <input type="submit" name="del" value="删除所选" onClick="return test();">
        <font color="#ff0000">注意:未选择则操作无效</font> </td>
    </tr>
    <tr align="center">
      <td class="cmsRow" colspan="9"><table width="95%"  border="0" cellpadding="0" cellspacing="0">
          <tr align="right">
            <td><%showpage "zh",1,"?selectm="&selectm&"&selectkey="&selectkey&"&lrc_select="&lrc_select&"&pic_select="&pic_select&"&classid="&request("classid")&"",totalnumber,MaxPerPage,true,true,"首",CurrentPage%></td>
          </tr>
        </table></td>
    </tr>
  </form>
</table>
<%
end sub

sub manage()
dim manage,pagetitle
'id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,istop,isdel,sn
dim id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,sn
if request("manage")="edit" then
'----------------------------------------------
manage="edit"
pagetitle="修改音乐"
set rs=conn.execute("select id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,sn from cfplay_list where id="&trim(request.QueryString("id"))&" ")
id=rs("id")
classid=rs("classid")
title=rs("title")
url=rs("url")
lrc=rs("lrc")
content=rs("content")
pic=rs("pic")
x=rs("x")
y=rs("y")
w=rs("w")
h=rs("h")
s=rs("s")
a=rs("a")
c=rs("c")
u=rs("u")
scene=rs("scene")
hits=rs("hits")
addtime=rs("addtime")
lasttime=SystemTime
isbest=rs("isbest")
sn=rs("sn")
rs.close
set rs=nothing
'----------------------------------------------
else
'----------------------------------------------
manage="add"
pagetitle="添加音乐"
classid=0
title=""
url=""
lrc=""
content=""
pic=""
x=""
y=""
w=""
h=""
s=""
a=""
c=""
u=""
scene=""
hits=0
addtime=SystemTime
lasttime=SystemTime
isbest=0
sn=""
'----------------------------------------------
end if
%>
<table border="0" align=center cellpadding="5" cellspacing="1" class="tableBorder">
  <form name="form_cfplay_list_manage" action="?action=save_manage&save_manage=<%=manage%>" method="post">
    <tr>
      <th colspan="4" align="center"><%=pagetitle%></th>
    </tr>
    <tr>
      <td align="right" nowrap class="cmsRow01"><strong>所属专辑:</strong></td>
      <td class="cmsRow01"><select name="classid" id="JumpClass">
          <%
sql="select classid,classname from cfplay_class order by sn"
set rs=conn.execute(sql)
	if rs.bof or rs.eof then
		Errmsg=Errmsg&"<li>至少需要一个专辑,请先<a href=""?action=class_manage""><strong>添加</strong></a>"
		cenfun_error()
		exit sub
	else
		do while not rs.eof
			response.write "<option value="&rs("classid")&""
				if rs("classid")=classid then
					response.write " selected"
				end if
			response.write ">"&rs("classname")&"</option>"			
			rs.movenext
		loop
	end if
rs.close
set rs=nothing
%>
        </select>
        <input type="hidden" value="<%=isbest%>" name="isbest"></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>音乐名称:</strong></td>
      <td class="cmsRow01"><input name="title" id="title" type="text" size="50" value="<%=title%>">
        <font color="red">*</font>
        <input type="button" value="检查重复" onClick="checktitle();">
        <%if request("manage")="edit" then%>
        <input name="id" type="hidden" value="<%=id%>">
        <%end if%></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>音乐介绍:</strong></td>
      <td class="cmsRow01"><input name="content" type="text" size="50" value="<%=content%>"></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>音乐地址:</strong></td>
      <td class="cmsRow01"><input name="url" type="text" value="<%=url%>" size="70">
        <font color="red">*</font> </td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>歌词地址:</strong></td>
      <td class="cmsRow01"><input name="lrc" id="lrc" type="text" size="70" value="<%=lrc%>">
        <input type="button" value="查看" onClick="showurl(document.getElementById('lrc'));">
        <input type="button" name="lrc_file" value="<%if request("manage")="edit" then%>编辑<%else%>添加<%end if%>歌词文件" onClick="showlrc();"/>
      </td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>图片地址:</strong></td>
      <td class="cmsRow01"><input name="pic" id="pic" type="text" size="70" value="<%=pic%>">
        <input type="button" value="查看" onClick="showurl(document.getElementById('pic'));"></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>图片属性:</strong></td>
      <td class="cmsRow01">x:
        <input name="x" type="text" size="3" value="<%=x%>">
        y:
        <input name="y" type="text" size="3" value="<%=y%>" />
        w:
        <input name="w" type="text" size="3" value="<%=w%>" />
        h:
        <input name="h" type="text" size="3" value="<%=h%>" />
        s:
        <input name="s" type="text" size="3" value="<%=s%>" />
        a:
        <input name="a" type="text" size="3" value="<%=a%>" />
        c:
        <input name="c" type="text" size="15" value="<%=c%>" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>图片链接:</strong></td>
      <td class="cmsRow01"><input name="u" id="u" type="text" size="70" value="<%=u%>" />
        <input type="button" value="打开" onClick="showurl(document.getElementById('u'));" />
        不填则默认为图片地址。</td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>场景地址:</strong></td>
      <td class="cmsRow01"><input name="scene" id="scene" type="text" size="70" value="<%=scene%>" />
        <input type="button" value="查看" onClick="showurl(document.getElementById('scene'));" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow01"><strong>序号:</strong></td>
      <td class="cmsRow01"><input name="sn" type="text" size="4" value="<%=sn%>"></td>
    </tr>
    <tr <%if not request("manage")="edit" then%>style="display: none;"<%end if%>>
      <td align="right" class="cmsRow01"><strong>添加时间:</strong></td>
      <td class="cmsRow01"><input name="addtime" id="addtime" type="text" size="20" value="<%=addtime%>">
        <input name="SqlNowString" type="button" onClick="document.getElementById('addtime').value='<%=lasttime%>'" value="更新"/></td>
    </tr>
    <tr <%if not request("manage")="edit" then%>style="display: none;"<%end if%>>
      <td align="right" class="cmsRow01"><strong>更新时间:</strong></td>
      <td class="cmsRow01"><input name="lasttime" type="text" size="20" value="<%=lasttime%>"></td>
    </tr>
    <tr>
      <td colspan="4" align="center" class="cmsRow01"><input type="button" class=button name="submit_cfplay_list_manage" value="<%=pagetitle%>" onClick="return check();">
      </td>
    </tr>
    <tr>
      <td colspan="4" class="cmsRow"><table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
            <td class="copyright"><span style="font-weight: bold">详细说明:</span><br>
              所属专辑:在<a href="?action=class_manage">专辑管理</a>中进行增删改管理。 <br>
              音乐名称:必填，建议按照[歌手 - 歌名]的格式填写。<br>
              音乐介绍:对音乐的补充介绍，如音乐风格，专辑介绍等。<br>
              音乐地址:必填，建议使用标准格式地址，如:http://www.cenfun.com/cenfun.mp3<br>
              歌词地址:可在线编辑，请先点击添加/编辑歌词文件，提交后系统自动返回歌词的调用地址。(存放在lrc目录)<br>
              图片地址:当前音乐特定的背景图片调用地址，建议使用jpg/swf格式438x120大小。(存放在bg目录)<br>
              图片属性:x:横坐标  y:纵坐标  w:宽度  h:高度  s:缩放百分比  a:默认显示透明度  c:介绍 <br>
              图片链接:点击图片介绍处打开的链接地址，不填则默认为图片地址。 <br>
              场景地址:当前音乐特定的flash场景调用地址,请使用swf格式438x120大小。(存放在scene目录)<br>
              序号:默认排列序号</td>
          </tr>
        </table></td>
    </tr>
  </form>
</table>
<script LANGUAGE="javascript">
<!--
function showurl(obj){
	if(obj.value!=''){
		var this_url=obj.value;
		var t=this_url.indexOf("http://");
		//alert(t);
		if(t!=-1){
			window.open(this_url,'','status=no,scrollbars=1')
		}else{
			window.open("../"+this_url,'','status=no,scrollbars=1')
		}
	}
}
function checktitle(){
	var this_title=document.getElementById('title').value;
	if(this_title!=''){
		var win='width=400,height=150,left='+(window.screen.width/2-200)+',top='+(window.screen.height/2-100)+',status=no,scrollbars=1';
		window.open('?nomenu=1&action=check_music_name&music_name='+this_title,'',win);
	}
}
function showlrc(){
	var this_title=document.getElementById('title').value;
	if(this_title!=''){
		var win='width=760,height=500,left='+(window.screen.width/2-380)+',top='+(window.screen.height/2-275)+',status=no,scrollbars=1';
		window.open('?nomenu=1&action=make_lrc&lrc_name='+this_title,'lrc_edit',win);
	}
}
function checkspace(s) {
  var str = '';
  for(i = 0; i < s.length; i++) {
    str = str + ' ';
  }
  return (str == s);
}
function check()
{
  if(checkspace(document.form_cfplay_list_manage.title.value)) {
	document.form_cfplay_list_manage.title.focus();
    alert("音乐名不能为空!");
	return false;
  }
  if (document.form_cfplay_list_manage.url.value=="")
  {
    alert("请填写音乐地址。");
	document.form_cfplay_list_manage.url.focus();
	return false;
  }
	document.form_cfplay_list_manage.submit();
  }
//-->
</script>
<%
end sub

Sub save_manage()
dim saveaction,sql
dim id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,sn
dim addtime_sql,lasttime_sql
	saveaction=request.QueryString("save_manage")
	classid=Request("classid")
		if classid="" then Errmsg=Errmsg&"<li>专辑不能为空!请返回重新填写信息!"
	title=Replace(trim(Request("title")),"'","")
		if title="" then Errmsg=Errmsg&"<li>名称不能为空!请返回重新填写信息!"
	url=Replace(trim(Request("url")),"'","")
		if url="" then Errmsg=Errmsg&"<li>地址不能为空!请返回重新填写信息!"
	lrc=Replace(trim(Request("lrc")),"'","")
	content=Replace(trim(Request("content")),"'","")
	pic=Replace(trim(Request("pic")),"'","")
	x=Replace(trim(Request("x")),"'","")
	y=Replace(trim(Request("y")),"'","")
	w=Replace(trim(Request("w")),"'","")
	h=Replace(trim(Request("h")),"'","")
	s=Replace(trim(Request("s")),"'","")
	a=Replace(trim(Request("a")),"'","")
	c=Replace(trim(Request("c")),"'","")
	u=Replace(trim(Request("u")),"'","")
	scene=Replace(trim(Request("scene")),"'","")
	hits=Replace(trim(Request("hits")),"'","")
	addtime=Request("addtime")
		if IsDate(addtime) then
			addtime_sql="addtime='"&addtime&"',"
		end if
	lasttime=Request("lasttime")
		if IsDate(lasttime) then
			lasttime_sql="lasttime='"&lasttime&"',"
		end if
	isbest=Request("isbest")
		if isbest<>1 then isbest=0
	sn=Replace(trim(Request("sn")),"'","")
		if sn="" then sn=0
if saveaction="edit" then
	saveaction=""
	id=Request("id")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_list Set classid="&classid&",title='"&title&"',url='"&url&"',lrc='"&lrc&"',content='"&content&"',pic='"&pic&"',x='"&x&"',y='"&y&"',w='"&w&"',h='"&h&"',s='"&s&"',a='"&a&"',c='"&c&"',u='"&u&"',scene='"&scene&"',isbest="&isbest&","&addtime_sql&""&lasttime_sql&"sn="&sn&" Where id="&id&"")
		SucMsg=SucMsg&"<li>修改资料成功!"
		Cenfun_suc("?")
	end if
end if

if saveaction="add" then
	saveaction=""
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		'response.write "classid="&classid&"/url="&url&"/isbest="&isbest
		sql="insert into cfplay_list (classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,addtime,lasttime,isbest,sn) values("&classid&",'"&title&"','"&url&"','"&lrc&"','"&content&"','"&pic&"','"&x&"','"&y&"','"&w&"','"&h&"','"&s&"','"&a&"','"&c&"','"&u&"','"&scene&"',"&SqlNowString&","&SqlNowString&","&isbest&","&sn&")"
		conn.execute(sql)
		SucMsg=SucMsg&"<li>添加成功!"
		Cenfun_suc("?")
	end if
end if
end sub

sub class_manage()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th colspan="6"><strong>专辑管理</strong></th>
  </tr>
  <tr class="cmsRow">
    <td>序号</td>
    <td>名称</td>
    <td>简介</td>
    <td>操作</td>
  </tr>
  <%
dim nextsn
	nextsn=1
	sql="select classid,classname,content,sn from cfplay_class order by sn"
	set rs=conn.execute(sql)
	if rs.EOF and rs.BOF then
		response.Write "<tr align=center><td colspan=4 class=cmsRow><font color=red>没有找到任何信息!</font></td></tr>"
	else
		do while not rs.EOF
%>
  <tr class="cmsRow">
    <td><input name="sn" type="text" id="sn<%=rs("classid")%>" size="4" value="<%=rs("sn")%>"></td>
    <td><input name="classname" type="text" id="classname<%=rs("classid")%>" size="15" value="<%=trim(rs("classname"))%>"></td>
    <td><input name="content" type="text" id="content<%=rs("classid")%>" size="30" value="<%=trim(rs("content"))%>"></td>
    <td><input name="edit" type="button"  value="修 改" onClick="document.location='?action=save_class_manage&class_manage=edit&classid=<%=rs("classid")%>&sn='+document.getElementById('sn<%=rs("classid")%>').value+'&classname='+document.getElementById('classname<%=rs("classid")%>').value+'&content='+document.getElementById('content<%=rs("classid")%>').value">
      <input type="button" name="del" value="删 除" onClick="if(confirm('删除专辑时，其下的音乐信息不会删除!确认删除吗？')){location='?action=save_class_manage&class_manage=del&classid=<%=rs("classid")%>'}"></td>
  </tr>
  <%
		nextsn=nextsn+1
		rs.MoveNext
		loop
	end if
	rs.close
	set rs=nothing
%>
  <form name="form_class_manage_add" method="post" action="?action=save_class_manage&class_manage=add">
    <tr class="cmsRow">
      <td><input name="sn" type="text" id="sn" size="4" value="<%=nextsn%>"></td>
      <td><input name="classname" type="text" id="classname" size="15" value=""></td>
      <td><input name="content" type="text" id="content" size="30" value=""></td>
      <td><input type="button" name="Submit" value="添 加" onClick="check();"></td>
    </tr>
  </form>
</table>
<script LANGUAGE="javascript">
<!--
function check(){
	if(isNaN(document.form_class_manage_add.sn.value)) {
		document.form_class_manage_add.sn.focus();
		document.form_class_manage_add.reset();
		alert("序号必须位数字");
	}else if(document.form_class_manage_add.sn.value=="") {
		document.form_class_manage_add.sn.focus();
		alert("序号不能为空");
	}else if(document.form_class_manage_add.classname.value=="") {
		document.form_class_manage_add.classname.focus();
		alert("名称不能为空");
	}else{
		document.form_class_manage_add.submit();
	}
}
//-->
</script>
<%
end sub

sub save_class_manage()
dim class_manage
class_manage=request.querystring("class_manage")
if class_manage="del" then
	conn.execute ("delete from cfplay_class where classid="&request.QueryString("classid"))
	SucMsg=SucMsg&"<li>删除成功!"
	'Cenfun_suc("?action=class_manage")
	response.Redirect("?action=class_manage")
else
	dim classname,content,sn
	classname=request("classname")
		if classname="" then Errmsg=Errmsg&"<li>名称不能为空！请返回重新填写信息！"
	content=request("content")
	sn=request("sn")
	If ErrMsg<>"" Then 
		cenfun_error()
	elseif class_manage="add" then
		sql="insert into cfplay_class"
		sql=sql&"(classname,content,sn) values"
		sql=sql&"('"&classname&"','"&content&"',"&sn&")"
		conn.execute(sql)
		SucMsg=SucMsg&"<li>添加成功!"
		Cenfun_suc("?action=class_manage")
	elseif class_manage="edit" then
		sql="update cfplay_class set "
		sql=sql&" classname='"&classname&"',content='"&content&"',sn="&sn&" where classid="&request.QueryString("classid")
		conn.execute(sql)
		SucMsg=SucMsg&"<li>修改成功!"
		'Cenfun_suc("?action=class_manage")
		response.Redirect("?action=class_manage")
	end if
end if
end sub

sub config()
On Error Resume Next
sql="select cflist,bg,scene,ads,readme,cfversion,copyright,other from cfplay_config"
set rs=conn.execute(sql)
if err<>0 then
	'response.write err
	'update db for config other
	Conn.ExeCute("ALTER TABLE [cfplay_config] ADD other TEXT")
	dim other_str
	other_str="autoplay="&Chr(13) & Chr(10)
	other_str=other_str&"lrccolor1=#008000"&Chr(13) & Chr(10)
	other_str=other_str&"lrccolor2=#84FF84"&Chr(13) & Chr(10)
	other_str=other_str&"listcolor1=#cccccc"&Chr(13) & Chr(10)
	other_str=other_str&"listcolor2=#00ff00"&Chr(13) & Chr(10)
	other_str=other_str&"classcolor1=#cccccc"&Chr(13) & Chr(10)
	other_str=other_str&"classcolor2=#00BD00"&Chr(13) & Chr(10)
	other_str=other_str&"bgcolor=#000000"
	Conn.ExeCute("update cfplay_config set other='"&other_str&"'")
	response.Redirect("?action=config")
else
	'response.write err
if not rs.eof then
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <form name="form_config" method="post" id="form_config" action="?action=save_config">
    <tr>
      <th colspan="3" align="center">播放器配置</th>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">名称:</td>
      <td class="cmsRow"><input name="copyright" type="text" id="copyright" size="30" value="<%=rs("copyright")%>"/>
        <a href="http://www.cenfun.com/cfplay/union/" target="_blank">加入联盟</a></td>
      <td class="cmsRow">在Flash右键菜单中显示。</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">播放器网址:</td>
      <td class="cmsRow"><input name="cfversion" type="text" id="cfversion" size="50" value="<%=rs("cfversion")%>"/>
        <br>
        <a href="union.asp"></a></td>
      <td class="cmsRow">可让更多的人看到您的播放器，请务必填写正确。</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">音乐列表设置:</td>
      <td class="cmsRow"><textarea name="cflist" cols="60" rows="8" id="cflist"><%=rs("cflist")%></textarea></td>
      <td class="cmsRow">生成列表xml时，<strong>系统将自动更新这里，无需手动修改。</strong></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">默认背景设置:</td>
      <td class="cmsRow"><textarea name="bg" cols="60" rows="5" id="bg"><%=rs("bg")%></textarea></td>
      <td class="cmsRow">背景图片/动画格式jpg/swf，推荐尺寸:438x120px <br />
        一行url标记为一个背景图片/动画，可任意添加多个。 <br />
        默认放在bg目录中。另见下面高级属性说明。</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">默认场景:</td>
      <td class="cmsRow"><textarea name="scene" cols="60" rows="5" id="scene"><%=rs("scene")%></textarea></td>
      <td class="cmsRow">场景格式swf，推荐尺寸:438x120px<br />
        一行scene标记为一个场景，可任意添加多个。<br />
        默认放在scene目录中。</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">公告设置:</td>
      <td class="cmsRow"><textarea name="ads" cols="60" rows="5" id="ads"><%=rs("ads")%></textarea></td>
      <td class="cmsRow">公告/广告列表，在音乐播放时随机从这个列表加载一个显示。 <br />
        一行txt标记为一条公告，可任意添加多个。</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">帮助信息:</td>
      <td class="cmsRow"><textarea name="readme" cols="60" rows="3" id="readme"><%=rs("readme")%></textarea></td>
      <td class="cmsRow">帮助说明，在播放音频mp3时，如果没有歌词则显示。<br />
        推荐不超过7行。</td>
    </tr>
    <tr>
      <td class="cmsRow" align="right">其他配置:</td>
      <td class="cmsRow"><textarea name="other" cols="60" rows="8" id="other"><%=rs("other")%></textarea></td>
      <td class="cmsRow">autoplay=(0不自动播放|1随机播放一首|其他值为播放第一首)<br />
        lrccolor1=(#008000歌词颜色)<br />
        lrccolor2=(#84FF84歌词加亮行颜色)<br />
        listcolor1=(#cccccc音乐列表颜色)<br />
        listcolor2=(#00ff00音乐列表加亮行颜色)<br />
        classcolor1=(#cccccc专辑列表颜色)<br />
        classcolor2=(#00BD00专辑列表加亮行颜色)<br />
        bgcolor=(#000000背景色)</td>
    </tr>
    <tr>
      <td class="cmsRow" colspan="3" align="center"><input type="button" onClick="check_config();" class=button name="submit_config" value=" 修 改 ">
        <input type="reset" class=button name="reset_config" value=" 取 消 ">
      </td>
    </tr>
    <tr>
      <td class="cmsRow" colspan="3"><div align="left" class="copyright">高级属性说明:<br />
          &lt;url   x=&quot;0&quot; y=&quot;-10&quot; w=&quot;145&quot; h=&quot;120&quot; s=&quot;70&quot; a=&quot;40&quot; c=&quot;&quot; u=&quot;&quot;   &gt;url&lt;/url&gt;<br />
          x:相对于播放器中背景显示窗口，图片/动画的x坐标，即左顶点（填写整数，可以负数）<br />
          y:y坐标，即上顶点，xy不填写则默认为左顶点(0,0)<br />
          w:图片/动画宽度（不推荐使用）<br />
          h:图片/动画高度（不推荐使用）<br />
          s:图片/动画缩放百分比（纵横一起缩放，推荐使用）<br />
          a:默认图片/动画透明度（默认为100）<br />
          c:小文字介绍（推荐5字符以内）<br />
          u:链接（点击介绍可打开，不填写则打开图片/动画地址）<br />
          以上属性为定制图片/动画所用，可以选择使用，也可不用，故推荐采用标准图片/动画格式尺寸（438x120px）<br />
          <a href="http://www.cenfun.com/cfplay/" target="_blank">更多说明&gt;&gt;</a></div></td>
    </tr>
  </form>
</table>
<script LANGUAGE="javascript">
<!--
function checkspace(s) {
  var str = '';
  for(i = 0; i < s.length; i++) {
    str = str + ' ';
  }
  return (str == s);
}
function check_config()
{
  if(checkspace(document.form_config.cflist.value)) {
	document.form_config.cflist.focus();
    alert("音乐列表不能为空!");
	return false;
  }
  if(checkspace(document.form_config.bg.value)) {
	document.form_config.bg.focus();
    alert("默认背景不能为空!");
	return false;
  }
  if(checkspace(document.form_config.scene.value)) {
	document.form_config.scene.focus();
    alert("默认场景不能为空!");
	return false;
  }
   if(checkspace(document.form_config.ads.value)) {
	document.form_config.ads.focus();
    alert("公告不能为空!");
	return false;
  }
	document.form_config.submit();
  }
//-->
</script>
<%
end if
end if
rs.close
set rs=nothing
end sub

sub save_config()
dim cflist,bg,scene,ads,readme,cfversion,copyright,other
	cflist=request("cflist")
		if cflist="" then Errmsg=Errmsg&"<li>播放列表不能为空!请返回重新填写信息!"
	bg=Request("bg")
		if bg="" then Errmsg=Errmsg&"<li>默认背景不能为空!请返回重新填写信息!"
	scene=Request("scene")
		if scene="" then Errmsg=Errmsg&"<li>默认场景不能为空!请返回重新填写信息!"
	ads=Request("ads")
		if ads="" then Errmsg=Errmsg&"<li>公告不能为空!请返回重新填写信息!"
	readme=Request("readme")		
	cfversion=Request("cfversion")
	copyright=Request("copyright")	
	other=Request("other")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_config Set cflist='"&cflist&"',bg='"&bg&"',scene='"&scene&"',ads='"&ads&"',readme='"&readme&"',cfversion='"&cfversion&"',copyright='"&copyright&"',other='"&other&"'")
		SucMsg=SucMsg&"<li>修改资料成功!"
		Cenfun_suc("?action=config")
	end if
end sub

Function Checkxml(Str)
	If Isnull(Str) Then
		Checkxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"<","&lt;")
	Str = Replace(Str,">","&gt;")
	Str = Replace(Str,"&","&amp;")
	Str = Replace(Str,"'","&apos;")
	Str = Replace(Str,Chr(34),"&quot;")
	Checkxml = Str
End Function
Function iCheckxml(Str)
	If Isnull(Str) Then
		iCheckxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"&lt;","<")
	Str = Replace(Str,"&gt;",">")
	Str = Replace(Str,"&amp;","&")
	Str = Replace(Str,"&apos;","'")
	'Str = Replace(Str,"&quot;",Chr(34))
	iCheckxml = Str
End Function

sub make_xml()
dim isnewlist,newlistname,listname
isnewlist=Checkxml(Request.Form("isnewlist"))
newlistname=Checkxml(Request.Form("newlistname"))
if isnewlist="1" and newlistname<>"" then
	listname=newlistname
else 
	listname="最近更新"
end if
%>
<table border="0" cellspacing="1" cellpadding="5" align="center" class="tableBorder">
  <tr>
    <th colspan="4" align="center">生成XML文件</th>
  </tr>
  <tr>
    <td align="right" class="cmsRow">注意:</td>
    <td class="cmsRow">所有的操作完成，最后请务必在这里生成xml文件方能更新信息!</td>
  </tr>
  <form name="makelistform" action="?action=make_xml&make_xml=make_list" method="post">
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">是否显示最新99条:</td>
      <td class="cmsRow">否
        <input name="isnewlist" type="radio" value="0" checked="checked" />
        是
        <input name="isnewlist" type="radio" value="1" <%if isnewlist="1" and newlistname<>"" then%>checked="checked"<%end if%> />
        最新列表标题
        <input name="newlistname" type="text" id="newlistname" value="<%=iCheckxml(listname)%>" />
      </td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">生成所有XML文件:</td>
      <td class="cmsRow"><input type="submit" class="button" name="submit_config2" value="点击生成"  style="width:120px;height:40px;cursor:hand;" /></td>
    </tr>
  </form>
  <%if request("make_xml")="make_list" then%>
  <tr>
    <td align="right" nowrap="nowrap" class="cmsRow">&nbsp;</td>
    <td class="cmsRow"><%
dim rsclass,num
num=0
dim cflist_str,cflist_save_str,file_server,file_path,file_name
file_server="xml/"
file_path="../xml/"
file_name="list"
dim xml_head,xml_foot
xml_head="<?xml version=""1.0"" encoding=""gb2312""?>"&"<list>"
xml_foot="</list>"
'####################make_default#######################
	cflist_str=xml_head
	set rs=conn.execute("select top 99 title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene from cfplay_list order by sn")
	do while not rs.eof	
		cflist_str=cflist_str&make_cflist_music(rs("title"),rs("url"),rs("lrc"),rs("content"),rs("pic"),rs("x"),rs("y"),rs("w"),rs("h"),rs("s"),rs("a"),rs("c"),rs("u"),rs("scene"))
	rs.movenext
	loop
	rs.close
	set rs=nothing
	cflist_str=cflist_str&	xml_foot
	if isnewlist="1" then
		make_file cflist_str,file_path&file_name&num&".xml"
		cflist_save_str=cflist_save_str&"<list name="""&newlistname&""""
		cflist_save_str=cflist_save_str&">"&file_server&file_name&num&".xml</list>"&Chr(13) & Chr(10)
		response.write "生成 <a href='"&file_path&file_name&num&".xml' target='_blank' style='color:#ff0000;'>"&iCheckxml(newlistname)&":"&file_path&file_name&num&".xml</a> 成功！<br>"
	end if
	num=num+1
'#######################################################
set rsclass=conn.execute("select classid,classname,content from cfplay_class order by sn")
do while not rsclass.eof
	cflist_str=xml_head
	set rs=conn.execute("select title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene from cfplay_list where classid="&rsclass("classid")&" order by sn")
	do while not rs.eof	
		cflist_str=cflist_str&make_cflist_music(rs("title"),rs("url"),rs("lrc"),rs("content"),rs("pic"),rs("x"),rs("y"),rs("w"),rs("h"),rs("s"),rs("a"),rs("c"),rs("u"),rs("scene"))
	rs.movenext
	loop
	rs.close
	set rs=nothing
	cflist_str=cflist_str&xml_foot
	make_file cflist_str,file_path&file_name&num&".xml"
	cflist_save_str=cflist_save_str&"<list name="""&Checkxml(rsclass("classname"))&""""
	cflist_save_str=cflist_save_str&">"&file_server&file_name&num&".xml</list>"&Chr(13) & Chr(10)
	response.write "生成 <a href='"&file_path&file_name&num&".xml' target='_blank' style='color:#ff0000;'>"&Checkxml(rsclass("classname"))&":"&file_path&file_name&num&".xml</a> 成功！<br>"
num=num+1
rsclass.movenext
loop
conn.execute("update cfplay_config set cflist='"&cflist_save_str&"'")
rsclass.close
set rsclass=nothing
'make config
dim config_str,file_path_name
file_path_name="../xml/config.xml"
sql="select cflist,bg,scene,ads,readme,cfversion,copyright,other from cfplay_config"
set rs=conn.execute(sql)
if not rs.eof then
	config_str="<?xml version=""1.0"" encoding=""gb2312""?>"
	config_str=config_str&"<config>"
		config_str=config_str&"<cflist>"
			config_str=config_str&rs("cflist")
		config_str=config_str&"</cflist>"
		config_str=config_str&"<bg>"
			config_str=config_str&rs("bg")
		config_str=config_str&"</bg>"
		config_str=config_str&"<scene>"
			config_str=config_str&rs("scene")
		config_str=config_str&"</scene>"
		config_str=config_str&"<ads>"
			config_str=config_str&rs("ads")
		config_str=config_str&"</ads>"
		config_str=config_str&"<readme>"&Checkxml(rs("readme"))&"</readme>"	
		config_str=config_str&"<other>"&Checkxml(rs("other"))&"</other>"	
		config_str=config_str&"<cfversion>"&Checkxml(rs("cfversion"))&"</cfversion>"
		config_str=config_str&"<copyright>"&Checkxml(rs("copyright"))&"</copyright>"
	config_str=config_str&"</config>"
	make_file config_str,file_path_name
	response.write "生成 <a href='"&file_path_name&"' target='_blank' style='color:#ff0000;'>配置文件:"&file_path_name&"</a> 成功!"		
else
	response.write "生成文件失败!没有任何信息!"
end if
rs.close
set rs=nothing
%>
    </td>
  </tr>
  <%end if%>
</table>
<%
end sub

function make_file(str,path)
    dim fs,fsowrite
	on error resume next
	Set fs=CreateObject("Scripting.fileSystemObject")
    	Set fsowrite = fs.CreateTextFile(server.MapPath(path),true)
        fsowrite.Write str
        fsowrite.close
		set fsowrite=nothing
	set fs=nothing
	if err.number<>0 then
		response.write "<center>"&Err.Description&"，您的空间不支持FSO，请同您的空间商联系，或者查看相关权限设置。</center>"
	end if
end function

function make_cflist_music(title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene)
	dim str
		str=str&"<m>"
			str=str&"<n>"&Checkxml(title)&"</n>"
			str=str&"<u>"&Checkxml(url)&"</u>"
			str=str&"<c>"&Checkxml(content)&"</c>"
			str=str&"<p"
			if x<>"" then str=str&" x="""&x&""""
			if y<>"" then str=str&" y="""&y&""""
			if w<>"" then str=str&" w="""&w&""""
			if h<>"" then str=str&" h="""&h&""""
			if s<>"" then str=str&" s="""&s&""""
			if a<>"" then str=str&" a="""&a&""""
			if c<>"" then str=str&" c="""&c&""""
			if u<>"" then str=str&" u="""&u&""""
			str=str&">"&Checkxml(pic)&"</p>"
			str=str&"<l>"&Checkxml(lrc)&"</l>"
			str=str&"<s>"&Checkxml(scene)&"</s>"		
		str=str&"</m>"
	make_cflist_music=str	
end function

sub check_music_name()
%>
<table border="0" cellspacing="2" cellpadding="5" align="center" width="95%">
  <tr>
    <td align="center"><%
	set rs=conn.execute("select title from cfplay_list Where title='"&request("music_name")&"'")
	if rs.eof then
		response.Write("可以添加!")
	else
		response.Write("已经存在<a href=""javascript:search_music_name('"&request("music_name")&"')""><font color=#ff0000>"&rs("title")&"</font></a>")
	end if
	rs.close
	set rs=nothing
%>
    </td>
  </tr>
  <tr>
    <td align="center"><input type="button" value="关 闭" onClick="window.close();" /></td>
  </tr>
</table>
<script language="JavaScript" type="text/javascript">
function search_music_name(music_name){
	opener.location="?selectkey="+music_name;
	window.close();
}
</script>
<%
end sub

sub make_lrc()
dim objFSO,objCountFile
dim lrc_name,lrc_content,lrc_path,root_lrc_path
'on error resume next
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
dim this_path,parent_path
this_path="http://"&Request.ServerVariables("HTTP_HOST")&left(Request.ServerVariables("PATH_INFO"),InStrRev(Request.ServerVariables("PATH_INFO"),"/")-1)
parent_path=left(this_path,InStrRev(this_path,"/"))
if request("make_lrc")="save" then
	lrc_content=request("lrc_content")
	lrc_path=request("lrc_path")
	if lrc_path<>"" and lrc_content<>"" then
		make_file lrc_content,lrc_path
		root_lrc_path=request("root_lrc_path")
%>
<script language="JavaScript" type="text/javascript">
//
function savepath(){
	opener.document.getElementById('lrc').value=document.getElementById('lrc_url').value;
	window.close();
}
function userpath1(){
	document.getElementById('lrc_url').value="<%=root_lrc_path%>";
}
function userpath2(){
	document.getElementById('lrc_url').value="<%=parent_path&root_lrc_path%>";
}
//
function copyToClipboard(obj){
	obj.select();
	rgn = obj.createTextRange();
	rgn.execCommand("Copy");
}

</script>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th align="center">歌词文件管理</th>
  </tr>
  <tr>
    <td align="center" class="cmsRow">歌词文件保存成功!</td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input name="radiobutton" type="radio" value="radiobutton" checked="checked" onClick="userpath1();" />
      使用相对地址
      <input type="radio" name="radiobutton" value="radiobutton" onClick="userpath2();" />
      使用绝对地址</td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input name="lrc_url" type="text" id="lrc_url" value="<%=root_lrc_path%>" size="70">
      <input type="button" name="Submit" value="复制到剪贴板" onClick="copyToClipboard(document.getElementById('lrc_url'));"></td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input type="button" name="Submit3" value="确 定" onClick="savepath()"></td>
  </tr>
</table>
<%
	end if
else
	lrc_name=request("lrc_name")&".txt"
	lrc_path="../lrc/"&lrc_name
	root_lrc_path="lrc/"&lrc_name
	if objFSO.FileExists(Server.MapPath(lrc_path)) then
		Set objCountFile = objFSO.OpenTextFile(Server.MapPath(lrc_path),1,False)
		If Not objCountFile.AtEndOfStream Then
			lrc_content = objCountFile.ReadAll
		else
			lrc_content = ""
		end if
		objCountFile.Close
		Set objCountFile=Nothing
	else
		lrc_content = ""
	end if
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <form name="lrc_file_form" action="?nomenu=1&action=make_lrc&make_lrc=save" method="post">
    <tr>
      <th colspan="4" align="center">歌词文件管理</th>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>文件名:</strong></td>
      <td class="cmsRow"><input type="text" size="50" name="lrc_name" value="<%=lrc_name%>" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>歌词内容:</strong><br />
        <br />
        [ti:歌名]<br />
        [ar:艺人]<br />
        [al:专辑]<br />
        [by:CenFun]<br />
        [offset:500]</td>
      <td class="cmsRow"><textarea name="lrc_content" rows="20" style="width:100%;"><%=lrc_content%></textarea></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>文件保存路径:</strong></td>
      <td class="cmsRow"><input type="text" size="70" name="lrc_path" value="<%=lrc_path%>" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>歌词使用地址:</strong></td>
      <td class="cmsRow"><input type="text" size="70" name="root_lrc_path" value="<%=root_lrc_path%>" /></td>
    </tr>
    <tr>
      <td colspan="2" align="center" class="cmsRow"><input type="button" onClick="check_lrc();" class="button" name="submit_lrc_file" value=" 提 交 " />
        <input type="reset" class="button" name="reset_lrc_file" value=" 取 消 " onClick="window.close();"/></td>
    </tr>
  </form>
</table>
<script language="JavaScript" type="text/javascript">
function check_lrc(){
	if(document.lrc_file_form.lrc_content.value==""){
		alert("歌词内容不能为空!");
		document.lrc_file_form.lrc_content.focus();
		return false;
	}
	if(document.lrc_file_form.lrc_path.value==""){
		alert("歌词文件保存路径不能为空!");
		document.lrc_file_form.lrc_path.focus();
		return false;
	}
	document.lrc_file_form.submit();
}
</script>
<%	
end if
Set objFSO = Nothing
if err.number<>0 then
	response.write "<center>"&Err.Description&"，您的空间不支持FSO，请同您的空间商联系，或者查看相关权限设置。</center>"
end if
end sub

sub show()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <td align="center" class="cmsRow"><embed src="../cfplay.swf?config=.." quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="450" height="320" id="cfplay"></embed>
    </td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><p>如果没有刷新,请确定点击了<a href="?action=make_xml">生成xml文件</a>功能，仍然没有刷新则清空您的浏览器缓存即可!</p></td>
  </tr>
</table>
<meta http-equiv=Pragma content=no-cache>
<meta http-equiv=expires content=0>
<meta http-equiv="cache-control" content="no-store">
<%
end sub
%>
