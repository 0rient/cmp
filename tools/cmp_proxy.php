<?php
//'CMP���ִ�������ʵ��Flash�����ȡ��Ϣ,�Լ�ͻ�Ʒ�����
//ע�⣺������Ϊphp�棬���Ŀռ����֧��php��ʹ�ù��ཫ����ط���������

$url = $_GET["url"];
$referer = $_GET["referer"];

if($url){

	$path_parts = pathinfo($url);
	$filename = $path_parts["basename"];

	header("Content-Type: application/force-download");
	header("Content-Disposition: attachment; filename=$filename");
	header("Content-Transfer-Encoding: binary");
	
	$str = "Referer: $referer";
	$context = array('http' => array ('header'=> $str));
	$xcontext = stream_context_create($context);
	
	$sFile = file_get_contents($url,false,$xcontext);
	
	if($sFile){
		echo $sFile;
	}else{
		header("location:$url");
	}
}

?>