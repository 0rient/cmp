<?php
//php���� ����ʵ��Flash�����ȡ��Ϣ�Լ�ͻ�Ʒ�����
$url = urldecode($_REQUEST["url"]);
if($url){
	$ref = urldecode($_REQUEST["ref"]);
	$str = "Referer: $ref";
	$context = array('http' => array ('header'=> $str));
	$xcontext = stream_context_create($context);
	$data = file_get_contents($url, false, $xcontext);
	echo $data;
}
?>